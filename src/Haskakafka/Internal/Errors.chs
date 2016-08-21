module Haskakafka.Internal.Errors
  (
  -- * Types
    RdKafkaErrDesc(..)
  , RdKafkaErrDescPtr

  -- * Function
  , rdKafkaGetErrDescs
  , rdKafkaGetDebugContexts

  , rdKafkaErr2str
  , rdKafkaErr2name
  ) where

import Foreign (Ptr)
import Foreign.C.Types (CSize)
import Haskakafka.Internal.CTypes (RdKafkaErrDesc(..), RdKafkaErrDescPtr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Return full list of error codes.
{#fun unsafe rd_kafka_get_err_descs
  as ^
  { id `Ptr RdKafkaErrDescPtr'
  -- ^ pointer to error description struct
  , id `Ptr CSize'
  -- ^ size of returned struct
  } -> `()' #}

-- | Retrieve comma separated list of supported debug contexts for use with the
-- "debug" configuration property.
{#fun unsafe rd_kafka_get_debug_contexts
  as ^
  {} -> `String' #}

-- | Return human readable representation of a Kafka error.
{#fun unsafe rd_kafka_err2str
  as ^
  { `RdKafkaRespErrT'
  } -> `String' #}

-- | Return enumeration name of a Kafka error.
{#fun unsafe rd_kafka_err2name
  as ^
  { `RdKafkaRespErrT'
  } -> `String' #}
