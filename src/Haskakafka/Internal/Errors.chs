module Haskakafka.Internal.Errors
  (
  -- * Descriptions
    rdKafkaGetErrDescs
  ) where

import Foreign (Ptr)
import Foreign.C.Types (CSize)

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
