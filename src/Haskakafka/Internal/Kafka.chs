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
