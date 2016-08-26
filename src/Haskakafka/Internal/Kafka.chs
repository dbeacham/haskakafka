{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Kafka
  (
  -- * Lifetime
    rdKafkaNew
  , rdKafkaDestroy

  -- * Information
  , rdKafkaName
  , rdKafkaOpaque

  -- * Operations
  , rdKafkaPoll
  , rdKafkaYield
  
  , rdKafkaPausePartitions
  , rdKafkaResumePartitions

  , rdKafkaQueryWatermarkOffsets
  , rdKafkaGetWatermarkOffsets

  -- * group lists
  , rdKafkaListGroups
  , rdKafkaGroupListDestroy
  
  -- * Misc
  , rdKafkaBrokersAdd
  ) where

import Foreign (Ptr, FunPtr, castPtr)
import Foreign.C.Types (CChar, CSize)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Create new kafka object.
{#fun unsafe rd_kafka_new
    as ^
    { `RdKafkaTypeT'
    , `RdKafkaConfTPtr'
    , id `Ptr CChar'
    , fromIntegral `CSize'
    } -> `RdKafkaTPtr' #}

-- | Destroy Kafka object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_destroy"
    rdKafkaDestroy :: FunPtr (Ptr RdKafkaT -> IO ())

-- | Return name of Kakfa handle.
{#fun unsafe rd_kafka_name
    as ^
    { `RdKafkaTPtr'
    } -> `String' #}

-- | Retrieves the opaque pointer previously set with
-- @rd_kafka_conf_set_opaque()@
{#fun unsafe rd_kafka_opaque
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  } -> `Ptr ()' #}

-- |
{#fun unsafe rd_kafka_poll
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `Int'
  } -> `Int' #}

-- |
{#fun unsafe rd_kafka_yield
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  } -> `()' #}

-- |
{#fun unsafe rd_kafka_pause_partitions
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `RdKafkaTopicPartitionListTPtr'
  } -> `RdKafkaRespErrT' #}

-- |
{#fun unsafe rd_kafka_resume_partitions
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `RdKafkaTopicPartitionListTPtr'
  } -> `RdKafkaRespErrT' #}

-- |
{#fun unsafe rd_kafka_query_watermark_offsets
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `String'
  , fromIntegral `CInt32T'
  , id `Ptr CInt64T'
  , id `Ptr CInt64T'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- |
{#fun unsafe rd_kafka_get_watermark_offsets
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `String'
  , fromIntegral `CInt32T'
  , id `Ptr CInt64T'
  , id `Ptr CInt64T'
  } -> `RdKafkaRespErrT' #}

-- |
{#fun unsafe rd_kafka_list_groups
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `String'
  , castPtr `Ptr (Ptr RdKafkaGroupListT)'
  , `Int'
  } -> `RdKafkaRespErrT' #}

foreign import ccall unsafe "rdkafka.h &rd_kafka_list_groups"
    rdKafkaGroupListDestroy :: FunPtr (Ptr RdKafkaGroupListT -> IO ())

-- |
{#fun unsafe rd_kafka_brokers_add
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  , `String'
  } -> `Int' #}

-- | Returns the current out queue length.

-- The out queue contains messages waiting to be sent to, or acknowledged by,
-- the broker.
-- 
-- An application should wait for this queue to reach zero before terminating
-- to make sure outstanding requests (such as offset commits) are fully
-- processed.
{#fun unsafe rd_kafka_outq_len
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  } -> `Int' #}

-- | Dumps rdkafka's internal state for handle rk to stream fp.

-- This is only useful for debugging rdkafka, showing state and statistics for
-- brokers, topics, partitions, etc.
{#fun unsafe rd_kafka_dump
  as ^
  { `CFilePtr'
  , `RdKafkaTPtr'
  } -> `()' #}

-- | Retrieve the current number of threads in use by librdkafka.
--
-- Used by regression tests.
{#fun unsafe rd_kafka_thread_cnt
  as ^
  {} -> `Int' #}

-- | Wait for all @rd_kafka_t@ objects to be destroyed.

-- Returns 0 if all kafka objects are now destroyed, or -1 if the timeout was
-- reached. Since @rd_kafka_destroy()@ is an asynch operation the
-- @rd_kafka_wait_destroyed()@ function can be used for applications where a
-- clean -- shutdown is required.
{#fun unsafe rd_kafka_wait_destroyed
  as ^
  { `Int'
  } -> `()' #}

-- | Redirect the main (@rd_kafka_poll()@) queue to the consumer's queue
-- (@rd_kafka_consumer_poll()@).

-- | Warning: It is not permitted to call rd_kafka_poll() after directing the
-- main queue with @rd_kafka_poll_set_consumer()@.
{#fun unsafe rd_kafka_poll_set_consumer
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka configuration object
  } -> `RdKafkaRespErrT' #}
