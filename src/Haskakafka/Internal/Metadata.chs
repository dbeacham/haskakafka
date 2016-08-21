{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Metadata
  (
    rdKafkaMetadata
  , rdKafkaMetadataDestroy
  ) where

import Foreign (Ptr, FunPtr, castPtr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Create a new list/vector topic+partition container.
{#fun unsafe rd_kafka_metadata
  as ^
  { `RdKafkaTPtr'
  , `Int'
  , `RdKafkaTopicTPtr'
  , castPtr `Ptr (Ptr RdKafkaMetadataT)'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- | Destroy a metadata object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_metadata_destroy"
  rdKafkaMetadataDestroy :: FunPtr (Ptr RdKafkaMetadataT -> IO ())
