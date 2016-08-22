{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.SimpleConsumer
  (
  -- * Topics
    rdKafkaConsumeStart
  , rdKafkaConsumeStartQueue
  , rdKafkaConsumeStop
  , rdKafkaSeek
  , rdKafkaConsume
  , rdKafkaConsumeBatch
  , rdKafkaConsumeCallback
  -- * Queues
  , rdKafkaConsumeQueue
  , rdKafkaConsumeBatchQueue
  , rdKafkaConsumeCallbackQueue
  , ConsumeCb
  , mkConsumeCb
  ) where

import Foreign.Ptr as C2HSImp
import Foreign.C.Types as C2HSImp

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

--------------------------------------------------------------------------------
-- * Topics
--------------------------------------------------------------------------------

-- |
{#fun rd_kafka_consume_start
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  , fromIntegral `CInt64T'
  } -> `Int' #}

-- |
{#fun rd_kafka_consume_start_queue
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  , fromIntegral `CInt64T'
  , `RdKafkaQueueTPtr'
  } -> `Int' #}

-- |
{#fun rd_kafka_consume_stop
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  } -> `Int' #}

-- |
{#fun rd_kafka_seek
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  , fromIntegral `CInt64T'
  , `Int'
  } -> `RdKafkaRespErrT' #}

-- |
{#fun rd_kafka_consume
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  , `Int'
  } -> `RdKafkaMessageTPtr' #}

-- |
{#fun rd_kafka_consume_batch
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  , `Int'
  , id `Ptr (Ptr RdKafkaMessageT)'
  , fromIntegral `CSize'
  } -> `CSSizeT' fromIntegral #}

-- |
foreign import ccall unsafe "rd_kafka.h rd_kafka_consume_callback"
  rdKafkaConsumeCallback
    :: Ptr RdKafkaQueueTPtr
    -> CInt32T
    -> Int
    -> FunPtr ConsumeCb
    -> Ptr ()
    -> IO Int

--------------------------------------------------------------------------------
-- * Queues
--------------------------------------------------------------------------------

{#fun rd_kafka_consume_queue
  as ^
  { `RdKafkaQueueTPtr'
  , `Int'
  } -> `RdKafkaMessageTPtr' #}

-- |
{#fun rd_kafka_consume_batch_queue
  as ^
  { `RdKafkaQueueTPtr'
  , `Int'
  , id `Ptr (Ptr RdKafkaMessageT)'
  , fromIntegral `CSize'
  } -> `CSSizeT' fromIntegral #}

-- |
foreign import ccall unsafe "rd_kafka.h rd_kafka_consume_callback_queue"
  rdKafkaConsumeCallbackQueue
    :: Ptr RdKafkaQueueTPtr
    -> Int
    -> FunPtr ConsumeCb
    -> Ptr ()
    -> IO Int

--------------------------------------------------------------------------------
-- * Callback
--------------------------------------------------------------------------------

type ConsumeCb
    =  Ptr RdKafkaMessageT
    -> Ptr ()
    -> IO ()

foreign import ccall safe "wrapper"
  mkConsumeCb :: ConsumeCb -> IO (FunPtr ConsumeCb)
