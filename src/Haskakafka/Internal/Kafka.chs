{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Kafka
  (
  -- * Lifetime
    rdKafkaNew
  , rdKafkaDestroy

  -- * Information
  , rdKafkaName
  ) where

import Foreign (Ptr, FunPtr)
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
