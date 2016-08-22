{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Producer
  (
    rdKafkaProduce
  , rdKafkaProduceBatch
  ) where

import Foreign (Ptr)
import Foreign.C (CSize)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Produce and send a single message to broker.
-- 
-- Returns 0 on success or -1 on error in which case errno is set accordingly:
--
-- *   ENOBUFS - maximum number of outstanding messages has been reached:
--     "queue.buffering.max.messages" (RD_KAFKA_RESP_ERR__QUEUE_FULL)
-- *   EMSGSIZE - message is larger than configured max size:
--     "messages.max.bytes". (RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE)
-- *   ESRCH - requested partition is unknown in the Kafka cluster.
--     (RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION)
-- *   ENOENT - topic is unknown in the Kafka cluster.
--     (RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC)
{#fun rd_kafka_produce
  as ^
  { `RdKafkaTopicTPtr'
  -- ^ pointer to Kafka topic object
  , fromIntegral `CInt32T'
  -- ^ target partition - either @RD_KAFKA_PARTITION_UA@ (unassigned) for
  -- automatic partitioning using the topic's partitioner function, or a fixed
  -- partition (0..N-1)
  , `Int'
  -- ^ msgflags is zero or more of the following flags OR:ed together:
  -- @RD_KAFKA_MSG_F_FREE@ - rdkafka will free(3) payload when it is done with
  -- it. @RD_KAFKA_MSG_F_COPY@ - the payload data will be copied and the
  -- payload pointer will not be used by rdkafka after the call returns.
  --
  -- @.._F_FREE@ and @.._F_COPY@ are mutually exclusive.
  --
  -- If the function returns -1 and RD_KAFKA_MSG_F_FREE was specified, then the
  -- memory associated with the payload is still the caller's responsibility.
  , `Ptr ()'
  -- ^ payload
  , fromIntegral `CSize'
  -- ^ length of payload in bytes
  , `Ptr ()'
  -- ^ optional message key. If non-NULL it will be passed to the topic
  -- partitioner as well as be sent with the message to the broker and passed on
  -- to the consumer.
  , fromIntegral `CSize'
  -- ^ length of message key in bytes
  , `Ptr ()'
  -- ^ optional application-provided per-message opaque pointer that will
  -- provided in the delivery report callback (dr_cb) for referencing this
  -- message.
  } -> `RdKafkaRespErrT' #}

-- | Produce multiple messages.
--
{#fun rd_kafka_produce_batch
  as ^
  { `RdKafkaTopicTPtr'
  -- ^ pointer to Kafka topic object
  , fromIntegral `CInt32T'
  -- ^ target partition - either @RD_KAFKA_PARTITION_UA@ (unassigned) for
  -- automatic partitioning using the topic's partitioner function, or a fixed
  -- partition (0..N-1)
  , `Int'
  -- ^ msgflags is zero or more of the following flags OR:ed together:
  -- @RD_KAFKA_MSG_F_FREE@ - rdkafka will free(3) payload when it is done with
  -- it. @RD_KAFKA_MSG_F_COPY@ - the payload data will be copied and the
  -- payload pointer will not be used by rdkafka after the call returns.
  --
  -- @.._F_FREE@ and @.._F_COPY@ are mutually exclusive.
  --
  -- If the function returns -1 and RD_KAFKA_MSG_F_FREE was specified, then the
  -- memory associated with the payload is still the caller's responsibility.
  , `RdKafkaMessageTPtr'
  -- ^ Array of messages. The partition and msgflags are used for all provided
  -- messages.
  --
  -- Honoured rkmessages[] fields are:

  -- *   @payload@ and @len@: Message payload and length
  -- *   @key@ and @key_len@: Optional message key
  -- *   @_private@: Message opaque pointer (msg_opaque)
  -- *   @err@: Will be set according to success or failure. Application only
  --     needs to check for errors if return value != message_cnt.
  , `Int'
  -- ^ number of messages
  }
  -> `Int'
  -- ^ Number of successfully enqueued messages
  #}
