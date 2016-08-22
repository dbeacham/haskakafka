{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.HighLevelConsumer
  (
    rdKafkaSubscribe
  , rdKafkaUnsubscribe
  , rdKafkaSubscription
  , rdKafkaConsumerPoll
  , rdKafkaConsumerClose
  , rdKafkaAssign
  , rdKafkaAssignment
  , rdKafkaCommit
  , rdKafkaCommitMessage
  , rdKafkaCommitted
  , rdKafkaPosition
  , rdKafkaMemberid
  ) where

import Foreign (Ptr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Subscribe to topic set using balanced consumer groups.
--
-- Wildcard (regex) topics are supported by the librdkafka assignor: any topic
-- name in the topics list that is prefixed with "^" will be regex-matched to
-- th full list of topics in the cluster and matching topics will be added to
-- the subscription list.
{#fun rd_kafka_subscribe
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaTopicPartitionListTPtr'
  } -> `RdKafkaRespErrT' #}

-- | Unsubscribe from the current subscription set.
{#fun rd_kafka_unsubscribe
  as ^
  { `RdKafkaTPtr'
  } -> `RdKafkaRespErrT' #}

-- | Returns the current topic subscription.
--
-- An error code on failure, otherwise topic is updated to point to a newly
-- allocated topic list (possibly empty).
--
-- The application is responsible for calling
-- @rd_kafka_topic_partition_list_destroy@ on the returned list.
{#fun rd_kafka_subscription
  as ^
  { `RdKafkaTPtr'
  , id `Ptr (Ptr RdKafkaTopicPartitionListT)'
  } -> `RdKafkaRespErrT' #}

-- | Poll the consumer for messages or events.
--
-- An application should make sure to call consumer_poll() at regular
-- intervals, even if no messages are expected, to serve any queued callbacks
-- waiting to be called. This is especially important when a rebalance_cb has
-- been registered as it needs to be called and handled properly to synchronize
-- internal consumer state.
--
-- A message object which is a proper message if @->err@ is
-- @RD_KAFKA_RESP_ERR_NO_ERROR@, or an event or error for any other value.
{#fun rd_kafka_consumer_poll
  as ^
  { `RdKafkaTPtr'
  , `Int'
  -- ^ Maximum time in milliseconds to block for
  } -> `RdKafkaMessageTPtr' #}

-- | Close down the consumer.
--
-- This call will block until the consumer has revoked its assignment, calling
-- the @rebalance_cb@ if it is configured, committed offsets to broker, and left
-- the consumer group. The maximum blocking time is roughly limited to
-- @session.timeout.ms@.
{#fun rd_kafka_consumer_close
  as ^
  { `RdKafkaTPtr'
  } -> `RdKafkaRespErrT' #}

-- | Atomic assignment of partitions to consume.
{#fun rd_kafka_assign
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaTopicPartitionListTPtr'
  } -> `RdKafkaRespErrT' #}

-- | Returns the current partition assignment.
--
-- The application is responsible for calling
-- @rd_kafka_topic_partition_list_destroy@ on the returned list.
{#fun rd_kafka_assignment
  as ^
  { `RdKafkaTPtr'
  , id `Ptr (Ptr RdKafkaTopicPartitionListT)'
  } -> `RdKafkaRespErrT' #}

-- | Commit offsets on broker for the provided list of partitions.
--
-- @offsets@ should contain topic, partition, offset and possibly metadata. If
-- offsets is @NULL@ the current partition assignment will be used instead.
--
-- If async is false this operation will block until the broker offset commit
-- is done, returning the resulting success or error code.
--
-- If a @rd_kafka_conf_set_offset_commit_cb()@ offset commit callback has been
-- configured a callback will be enqueued for a future call to
-- @rd_kafka_poll()@.
{#fun rd_kafka_commit
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaTopicPartitionListTPtr'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- | Commit message's offset on broker for the message's partition. 
{#fun rd_kafka_commit_message
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaMessageTPtr'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- | Retrieve committed offsets for topics+partitions.
--
-- The offset field of each requested partition will either be set to stored
-- offset or to @RD_KAFKA_OFFSET_INVALID@ in case there was no stored offset for
-- that partition.
{#fun rd_kafka_committed
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaTopicPartitionListTPtr'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- | Retrieve current positions (offsets) for topics+partitions.
--
-- The offset field of each requested partition will be set to the offset of
-- the last consumed message + 1, or @RD_KAFKA_OFFSET_INVALID@ in case there was
-- no previous message.
{#fun rd_kafka_position
  as ^
  { `RdKafkaTPtr'
  , `RdKafkaTopicPartitionListTPtr'
  } -> `RdKafkaRespErrT' #}

-- | 
{#fun rd_kafka_memberid
  as ^
  { `RdKafkaTPtr'
  } -> `String' #}
