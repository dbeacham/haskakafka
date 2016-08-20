{-# LANGUAGE EmptyDataDecls #-}

-- | Message queues allows the application to re-route consumed messages from
-- multiple topics and partitions into one single queue point. This queue point
-- containing messages from a number of topic and partitions may then be served
-- by a single @rd_kafka_consume*_queue()@ call, rather than one call per
-- topic/partition combination.

module Haskakafka.Internal.Queue
  (
  -- * Lifetime
    rdKafkaQueueNew
  , rdKafkaQueueDestroy
  ) where

import Foreign (Ptr, FunPtr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Create new Kafka queue object.
{#fun unsafe rd_kafka_queue_new
    as ^
    { `RdKafkaTPtr'
    } -> `RdKafkaQueueTPtr' #}

-- | Destroy Kafka queue object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_queue_destroy"
    rdKafkaQueueDestroy :: FunPtr (Ptr RdKafkaQueueT -> IO ())
