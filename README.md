# Haskakafka

Kafka bindings for Haskell backed by the
[librdkafka C module](https://github.com/edenhill/librdkafka). It has been tested and fully
supports Kafka 0.9.0.1 using librdkafka 0.9.0.99 and higher on Linux and OS X. Haskakafka supports
both producers and consumers with optional batch operations.

Hackage: http://hackage.haskell.org/package/haskakafka

# Usage
A quick walkthrough of producers and consumers:
```Haskell
import Haskakafka

import qualified Data.ByteString.Char8 as C8

example :: IO ()
example = do
  let
      -- Optionally, we can configure certain parameters for Kafka
      kafkaConfig = [("socket.timeout.ms", "50000")]
      topicConfig = [("request.timeout.ms", "50000")]

      -- Payloads are just ByteStrings
      samplePayload = C8.pack "Hello world"


  -- withKafkaProducer opens a producer connection and gives us
  -- two objects for subsequent use.
  withKafkaProducer kafkaConfig topicConfig
                    "localhost:9092" "test_topic"
                    $ \kafka topic -> do

    -- Produce a single unkeyed message to partition 0
    let message = KafkaProduceMessage samplePayload
    _ <- produceMessage topic (KafkaSpecifiedPartition 0) message

    -- Produce a single keyed message
    let keyMessage = KafkaProduceKeyedMessage (C8.pack "Key") samplePayload
    _ <- produceKeyedMessage topic keyMessage

    -- We can also use the batch API for better performance
    _ <- produceMessageBatch topic KafkaUnassignedPartition [message, keyMessage]

    putStrLn "Done producing messages, here was our config: "
    dumpConfFromKafka kafka >>= \d -> putStrLn $ "Kafka config: " ++ (show d)
    dumpConfFromKafkaTopic topic >>= \d -> putStrLn $ "Topic config: " ++ (show d)


  -- withKafkaConsumer opens a consumer connection and starts consuming
  let partition = 0
  withKafkaConsumer kafkaConfig topicConfig
                    "localhost:9092" "test_topic"
                    partition -- locked to a specific partition for each consumer
                    KafkaOffsetBeginning -- start reading from beginning (alternatively, use
                                         -- KafkaOffsetEnd, KafkaOffset or KafkaOffsetStored)
                    $ \kafka topic -> do
    -- Consume a single message at a time
    let timeoutMs = 1000
    me <- consumeMessage topic partition timeoutMs
    case me of
      (Left err) -> putStrLn $ "Uh oh, an error! " ++ (show err)
      (Right m) -> putStrLn $ "Woo, payload was " ++ (C8.unpack $ messagePayload m)

    -- For better performance, consume in batches
    let maxMessages = 10
    mes <- consumeMessageBatch topic partition timeoutMs maxMessages
    case mes of
      (Left err) -> putStrLn $ "Something went wrong in batch consume! " ++ (show err)
      (Right ms) -> putStrLn $ "Woohoo, we got " ++ (show $ length ms) ++ " messages"


    -- Be a little less noisy
    setLogLevel kafka KafkaLogCrit

  -- we can also fetch metadata about our Kafka infrastructure
  let timeoutMs = 1000
  emd <- fetchBrokerMetadata [] "localhost:9092" timeoutMs
  case emd of
    (Left err) -> putStrLn $ "Uh oh, error time: " ++ (show err)
    (Right md) -> putStrLn $ "Kafka metadata: " ++ (show md)
```

## Configuration Options
Configuration options are set in the call to `withKafkaConsumer` and `withKafkaProducer`. For
the full list of supported options, see
[librdkafka's list](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md).

# High Level Consumers
High level consumers are supported by librdkafka starting from version 0.9.
High-level consumers have the ability to handle more than one partition and even more than one topic.
Scalability and rebalancing are taken care of by librdkafka: once a new consumer in the same
consumer group is started the rebalance happens and all consumer share the load.

This version of Haskakafka adds (experimental) support for high-level consumers,
here is how such a consumer can be used in code:

```Haskell
import           Haskakafka
import           Haskakafka.Consumer

runConsumerExample :: IO ()
runConsumerExample = do
    res <- runConsumer
              (ConsumerGroupId "test_group")    -- group id is required
              []                                -- extra kafka conf properties
              (BrokersString "localhost:9092")  -- kafka brokers to connect to
              [TopicName "^hl-test*"]           -- list of topics to consume, supporting regex
              processMessages                   -- handler to consume messages
    print $ show res

-- this function is used inside consumer
-- and it is responsible for polling and handling messages
-- In this case I will do 10 polls and then return a success
processMessages :: Kafka -> IO (Either KafkaError ())
processMessages kafka = do
    mapM_ (\_ -> do
                   msg1 <- pollMessage kafka 1000
                   print $ show msg1) [1..10]
    return $ Right ()

```

# Installation

## Installing librdkafka

Although librdkafka is available on many platforms, most of
the distribution packages are too old to support haskakafka.
As such, we suggest you install from the source:

    git clone https://github.com/edenhill/librdkafka
    cd librdkafka
    ./configure
    make && sudo make install

If the C++ bindings fail for you, just install the C bindings alone.

    cd librdkafka/src
    make && sudo make install

On Debian and OS X, this will install the shared and static libraries to `/usr/local/lib`.

## Installing Kafka

The full Kafka guide is at http://kafka.apache.org/documentation.html#quickstart

## Installing Haskakafka

If you want to use cabal—since haskakafka uses `c2hs` to generate C bindings—you may need to
explicitly install `c2hs` somewhere on your path (i.e. outside of a sandbox).
To do so, run:

    cabal install c2hs

Afterwards installation should work, so go for

    cabal install haskakafka

This uses the latest version of Haskakafka from [Hackage](http://hackage.haskell.org/package/haskakafka).

# Testing

Haskakafka ships with a suite of integration tests to verify the library against
a live Kafka instance. To get these setup you must have a broker running
on `localhost:9092` (or overwrite the `HASKAKAFKA_TEST_BROKER` environment variable)
with a `haskakafka_tests` topic created (or overwrite the `HASKAKAFKA_TEST_TOPIC`
environment variable).

To get a broker running, download a [Kafka distribution](http://kafka.apache.org/downloads.html)
and untar it into a directory. From there, run zookeeper using

    bin/zookeeper-server-start.sh config/zookeeper.properties

and run kafka in a separate window using

    bin/kafka-server-start.sh config/server.properties

With both Kafka and Zookeeper running, you can run tests through stack:

    stack test

You can also run tests through cabal:

    cabal install --only-dependencies --enable-tests
    cabal test --log=/dev/stdout

# Running Examples

    stack build
    stack exec -- basic --help

```
basic example [OPTIONS]
  Fetch metadata, produce, and consume a message

Common flags:
  -b       --brokers=<brokers>  Comma separated list in format
                                <hostname>:<port>,<hostname>:<port>
  -t       --topic=<topic>      Topic to fetch / produce
  -C       --consumer           Consumer mode
  -P       --producer           Producer mode
  -L       --list               Metadata list mode
  -A       --all                Run producer, consumer, and metadata list
  -p=<num>                      Partition (-1 for random partitioner when
                                using producer)
           --pretty             Pretty print output
  -?       --help               Display help message
  -V       --version            Print version information
```

The following will produce 11 messages on partition 5 for topic `test_topic`:

    stack exec -- basic -b "broker1.example.com:9092,broker2.example.com:9092,broker3.example.com:9092" -t test_topic -p 5 -P

The following will consume 11 messages on partition 5 for topic `test_topic`:

    stack exec -- basic -b "broker1.example.com:9092,broker2.example.com:9092,broker3.example.com:9092" -t test_topic -p 5 -C

The following will pretty print a list of all brokers and topics:

    stack exec -- basic -b "broker1.example.com:9092,broker2.example.com:9092,broker3.example.com:9092" -L --pretty


# Todo

## Version
[X] `rd_kafka_version`
[X] `rd_kafka_version_str`

## Errors
[X] `rd_kafka_get_err_descs`

[X] `rd_kafka_get_debug_contexts`
[X] `rd_kafka_err2str`
[X] `rd_kafka_err2name`

## Configuration

### Global
[X] `rd_kafka_conf_new`
[X] `rd_kafka_conf_destroy`
[X] `rd_kafka_conf_dup`

[X] `rd_kafka_conf_set`
[X] `rd_kafka_conf_set_default_topic_conf`
[X] `rd_kafka_conf_get`

[ ] `rd_kafka_conf_set_opaque`
[ ] `rd_kafka_conf_set_dr_cb`
[ ] `rd_kafka_conf_set_dr_msg_cb`
[ ] `rd_kafka_conf_set_consume_cb`
[ ] `rd_kafka_conf_set_rebalance_cb`
[ ] `rd_kafka_conf_set_offset_commit_cb`
[ ] `rd_kafka_conf_set_error_cb`
[ ] `rd_kafka_conf_set_throttle_cb`
[ ] `rd_kafka_conf_set_log_cb`
[ ] `rd_kafka_conf_set_stats_cb`
[ ] `rd_kafka_conf_set_socket_cb`
[ ] `rd_kafka_conf_set_open_cb`

### Topic
[X] `rd_kafka_topic_conf_new`
[X] `rd_kafka_topic_conf_dup`
[X] `rd_kafka_topic_conf_destroy`
[X] `rd_kafka_topic_conf_set`

[ ] `rd_kafka_topic_conf_set_opaque`
[ ] `rd_kafka_topic_conf_get`

### Partitioning
[ ] `rd_kafka_topic_conf_set_partitioner_cb`
[ ] `rd_kafka_topic_partition_available` (Must be called within partioning function)
[ ] `rd_kafka_msg_partitioner_random`
[ ] `rd_kafka_msg_partitioner_consistent`
[ ] `rd_kafka_msg_partitioner_consistent_random`

### Logging
[X] `rd_kafka_set_log_level`

### Display
[ ] `rd_kafka_conf_dump`
[ ] `rd_kafka_topic_conf_dump`
[ ] `rd_kafka_conf_dump_free`
[ ] `rd_kafka_conf_properties_show`

## Topic
[X] `rd_kafka_topic_new`
[X] `rd_kafka_topic_destroy`
[X] `rd_kafka_topic_name`
[X] `rd_kafka_topic_opaque`

## Topic partition
[ ] `rd_kafka_topic_partition_list_new`
[ ] `rd_kafka_topic_partition_list_destroy`
[ ] `rd_kafka_topic_partition_list_add`
[ ] `rd_kafka_topic_partition_list_add_range`
[ ] `rd_kafka_topic_partition_list_del`
[ ] `rd_kafka_topic_partition_list_del_by_idx`
[ ] `rd_kafka_topic_partition_list_copy`
[ ] `rd_kafka_topic_partition_list_set_offset`
[ ] `rd_kafka_topic_partition_list_find`

## Kafka
[X] `rd_kafka_new`
[X] `rd_kafka_destroy`
[X] `rd_kafka_name`

## Message
[X] `rd_kafka_message_destroy`
[X] `rd_kafka_message_errstr`
[X] `rd_kafka_message_timestamp`

## Queue
[X] `rd_kafka_queue_new`
[X] `rd_kafka_queue_destroy`

## Legacy consumer API
[ ] `rd_kafka_last_error`

### Errors
[ ] `rd_kafka_errno`
[ ] `rd_kafka_errno2err`

## Simple API
[ ] `rd_kafka_consume_start`
[ ] `rd_kafka_consume_start_queue`
[ ] `rd_kafka_consume_stop`
[ ] `rd_kafka_seek`
[ ] `rd_kafka_consume`
[ ] `rd_kafka_consume_batch`
[ ] `rd_kafka_consume_callback`

### Queue
[ ] `rd_kafka_consume_queue`
[ ] `rd_kafka_consume_batch_queue`
[ ] `rd_kafka_consume_callback_queue`

### Topic/parition offset
[ ] `rd_kafka_offset_store`

## High level consumer API
[ ] `rd_kafka_subscribe`
[ ] `rd_kafka_unsubscribe`
[ ] `rd_kafka_subscription`
[ ] `rd_kafka_consumer_poll`
[ ] `rd_kafka_consumer_close`
[ ] `rd_kafka_assign`
[ ] `rd_kafka_assignment`
[ ] `rd_kafka_commit`
[ ] `rd_kafka_commit_message`
[ ] `rd_kafka_committed`
[ ] `rd_kafka_position`

## Metadata
[ ] `rd_kafka_metadata`
[ ] `rd_kafka_metadata_destroy`

## Producer API
[ ] `rd_kafka_produce`
[ ] `rd_kafka_produce_batch`

## Deprecated
[] `rd_kafka_set_logger`
[] `rd_kafka_log_print`
[] `rd_kafka_log_syslog`

## Unsorted
[ ] `rd_kafka_memberid`
[ ] `rd_kafka_opaque`
[ ] `rd_kafka_poll`
[ ] `rd_kafka_yield`
[ ] `rd_kafka_pause_partitions`
[ ] `rd_kafka_resume_partitions`
[ ] `rd_kafka_query_watermark_offsets`
[ ] `rd_kafka_get_watermark_offsets`
[ ] `rd_kafka_mem_free`
[ ] `rd_kafka_list_groups`
[ ] `rd_kafka_group_list_destroy`
[ ] `rd_kafka_brokers_add`
[ ] `rd_kafka_outq_len`
[ ] `rd_kafka_dump`
[ ] `rd_kafka_thread_cnt`
[ ] `rd_kafka_wait_destroyed`
[ ] `rd_kafka_poll_set_consumer`
