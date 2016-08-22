module Haskakafka.Internal.SimpleError
  ( rdKafkaLastError
  ) where

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Returns the last error code generated by a legacy API call in the current
-- thread.
--
-- The legacy APIs are the ones using errno to propagate error value, namely:
--
-- *   @rd_kafka_topic_new()@
-- *   @rd_kafka_consume_start()@
-- *   @rd_kafka_consume_stop()@
-- *   @rd_kafka_consume()@
-- *   @rd_kafka_consume_batch()@
-- *   @rd_kafka_consume_callback()@
-- *   @rd_kafka_consume_queue()@
-- *   @rd_kafka_produce()@
--
-- The main use for this function is to avoid converting system errno values to
-- @rd_kafka_resp_err_t@ codes for legacy APIs.

-- Note: The last error is stored per-thread, if multiple rd_kafka_t handles
-- are used in the same application thread the developer needs to make sure
-- @rd_kafka_last_error()@ is called immediately after a failed API call.
{#fun unsafe rd_kafka_last_error
  as ^
  {} -> `RdKafkaRespErrT' #}