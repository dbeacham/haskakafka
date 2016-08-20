{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Message
  (
  -- * Lifetime
    rdKafkaMessageDestroy

  -- * Properties
  , rdKafkaMessageErrstr
  , rdKafkaMessageTimestamp
  ) where

import Foreign (Ptr, FunPtr)
import Foreign.C.Types

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Destroy Kafka message object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_message_destroy"
    rdKafkaMessageDestroy :: FunPtr (Ptr RdKafkaMessageT -> IO ())

-- | Returns the error string for an errored @rd_kafka_message_t@ or @NULL@ if
-- there was no error. 
{#fun unsafe rd_kafka_message_errstr
    as ^
    { `RdKafkaMessageTPtr'
    } -> `String' #}

-- | Returns the message timestamp for a consumed message.
{#fun unsafe rd_kafka_message_timestamp
    as ^
    { `RdKafkaMessageTPtr'
    -- ^ pointer to Kafka message
    , `RdKafkaTimestampTypeTPtr'
    -- ^ pointer to timestamp type that is updated to indicate type of
    -- timestamp
    } -> `Int'
    -- ^ number of milliseconds since epoch (UTC) or -1 if not available
    #}
