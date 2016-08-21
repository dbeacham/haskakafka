{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Configuration
  (
  -- * Global configuration
  -- ** Types
    RdKafkaConfT
  , RdKafkaConfTPtr

  -- ** Lifetime
  , rdKafkaConfNew
  , rdKafkaConfDup
  , rdKafkaConfDestroy

  -- ** Getters and setters
  , rdKafkaConfSet
  , rdKafkaConfSetDefaultTopicConf
  , rdKafkaConfGet

  -- ** Callbacks
  , rdKafkaConfSetOpaque

  -- *** Delivery report message callback
  , DrMsgCb
  , mkDrMsgCb
  , rdKafkaConfSetDrMsgCb

  -- *** Consume callback
  , ConsumeCb
  , mkConsumeCb
  , rdKafkaConfSetConsumeCb

  -- *** Rebalance callback
  , RebalanceCb
  , mkRebalanceCb
  , rdKafkaConfSetRebalanceCb
  
  -- *** Offset commit callback
  , OffsetCommitCb
  , mkOffsetCommitCb
  , rdKafkaConfSetOffsetCommitCb

  -- *** Error callback
  , ErrorCb
  , mkErrorCb
  , rdKafkaConfSetErrorCb

  -- *** Throttle callback
  , ThrottleCb
  , mkThrottleCb
  , rdKafkaConfSetThrottleCb

  -- *** Log callback
  , LogCb
  , mkLogCb
  , rdKafkaConfSetLogCb

  -- *** Stats callback
  , StatsCb
  , mkStatsCb
  , rdKafkaConfSetStatsCb

  -- *** Socket callback
  , SocketCb
  , mkSocketCb
  , rdKafkaConfSetSocketCb

  -- *** Open callback
  , OpenCb
  , mkOpenCb
  , rdKafkaConfSetOpenCb

  -- * Topic configuration
  -- ** Types
  , RdKafkaTopicConfT
  , RdKafkaTopicConfTPtr

  -- ** Lifetime
  , rdKafkaTopicConfNew
  , rdKafkaTopicConfDup
  , rdKafkaTopicConfDestroy
  --, rdKafkaTopicSetOpaque

  -- ** Getters and setters
  , rdKafkaTopicConfSet
  , rdKafkaTopicConfGet

  -- ** Callbacks
  , rdKafkaTopicConfSetOpaque

  -- *** Partitioning
  , mkPartitionerCallback
  , rdKafkaTopicConfSetPartitionerCb
  , rdKafkaTopicPartitionAvailable
  , rdKafkaMsgPartitionerRandom
  , rdKafkaMsgPartitionerConsistent
  , rdKafkaMsgPartitionerConsistentRandom

  -- * Displaying properties
  , rdKafkaConfDump
  , rdKafkaTopicConfDump
  , rdKafkaConfDumpFree
  , rdKafkaConfPropertiesShow

  -- * Logging
  , rdKafkaSetLogLevel
  ) where

import Foreign (Ptr, FunPtr, castPtr, withForeignPtr)
import Foreign.C.String (CString)
import Foreign.C.Types (CSize, CChar, CInt)
import System.Posix.Types (CMode(..))
--import Haskakafka.Internal.CTypes (CInt32T)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

--------------------------------------------------------------------------------
-- * Global configuration
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ** Lifetime
--------------------------------------------------------------------------------

-- | Create a new configuration object with defaults set.
{#fun unsafe rd_kafka_conf_new
  as ^
  {} -> `RdKafkaConfTPtr' #}

-- | Duplicate a copy of a configuration object.
{#fun unsafe rd_kafka_conf_dup
  as ^
  { `RdKafkaConfTPtr'
  -- ^ pointer to existing configuration object
  } -> `RdKafkaConfTPtr' #}

-- | Destroy a configuration object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_conf_destroy"
  rdKafkaConfDestroy :: FunPtr (Ptr RdKafkaConfT -> IO ())

--------------------------------------------------------------------------------
-- ** Getters and setters
--------------------------------------------------------------------------------

-- | Set a configuration value.
{#fun unsafe rd_kafka_conf_set
  as ^
  { `RdKafkaConfTPtr'
  -- ^ pointer to configuration object
  , `String'
  -- ^ configuration name
  , `String'
  -- ^ configuration value
  , id `Ptr CChar'
  -- ^ pointer to error string to populate in case of failure
  , fromIntegral `CSize'
  -- ^ size of error string
  } -> `RdKafkaConfResT' #}

-- | Sets the default topic configuration to use for automatically subscribed
-- topics (e.g., through pattern-matched topics). The topic config object is not
-- usable after this call.
{#fun unsafe rd_kafka_conf_set_default_topic_conf
  as ^
  { `RdKafkaConfTPtr'
  , `RdKafkaTopicConfTPtr'
  } -> `()' #}

-- | Get a configuration property by name.
{#fun unsafe rd_kafka_conf_get
  as ^
  { `RdKafkaConfTPtr'
  , `String'
  , id `Ptr CChar'
  , `CSizePtr'
  } -> `RdKafkaConfResT' #}

--------------------------------------------------------------------------------
-- ** Callbacks
--------------------------------------------------------------------------------

-- | Sets the application's opaque pointer that will be passed to callbacks.
{#fun unsafe rd_kafka_conf_set_opaque
  as ^
  { `RdKafkaConfTPtr'
  -- ^ pointer to Kafka configuration object
  , `Ptr ()'
  -- ^ pointer to be passed to callbacks
  } -> `()' #}

-- | Form of set callback functions
type RdKafkaSetConfCb a = Ptr RdKafkaConfT -> FunPtr a -> IO ()

-- | Form of callback wrappers
type MkKafkaConfCb a = a -> IO (FunPtr a)

-- | Convenience function for setting callback functions
rdKafkaConfSetCb
    :: MkKafkaConfCb cb
    -- ^ Function to convert callback to wrapped ffi version
    -> RdKafkaSetConfCb cb
    -- ^ Function to call to set callback
    -> RdKafkaConfTPtr
    -- ^ Kafka configuration object to set callback on
    -> cb
    -- ^ The callback to be called
    -> IO ()
rdKafkaConfSetCb mkCb setCb conf cb = do
  cb' <- mkCb cb
  withForeignPtr conf $ \c -> setCb c cb'
  return ()

--------------------------------------------------------------------------------
-- *** Delivery report
--------------------------------------------------------------------------------

-- | Producer: Set delivery report callback in provided conf object.
--
-- The delivery report callback will be called once for each message accepted
-- by rd_kafka_produce() (et.al) with err set to indicate the result of the
-- produce request.
-- 
-- The callback is called when a message is succesfully produced or if
-- librdkafka encountered a permanent failure, or the retry counter for
-- temporary errors has been exhausted.
-- 
-- An application must call rd_kafka_poll() at regular intervals to serve
-- queued delivery report callbacks.
type DrMsgCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka object
  -> Ptr RdKafkaMessageT
  -- ^ pointer to Kafka message object
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkDrMsgCb :: MkKafkaConfCb DrMsgCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_dr_msg_cb"
  rdKafkaConfSetDrMsgCb' :: RdKafkaSetConfCb DrMsgCb

rdKafkaConfSetDrMsgCb :: RdKafkaConfTPtr -> DrMsgCb -> IO ()
rdKafkaConfSetDrMsgCb = rdKafkaConfSetCb mkDrMsgCb rdKafkaConfSetDrMsgCb'

--------------------------------------------------------------------------------
-- *** Consume
--------------------------------------------------------------------------------
type ConsumeCb
  =  Ptr RdKafkaMessageT
  -- ^ pointer to Kafka message object
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkConsumeCb :: MkKafkaConfCb ConsumeCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_consume_cb"
  rdKafkaConfSetConsumeCb' :: RdKafkaSetConfCb ConsumeCb

rdKafkaConfSetConsumeCb :: RdKafkaConfTPtr -> ConsumeCb -> IO ()
rdKafkaConfSetConsumeCb = rdKafkaConfSetCb mkConsumeCb rdKafkaConfSetConsumeCb'

--------------------------------------------------------------------------------
-- *** Rebalance
--------------------------------------------------------------------------------
type RebalanceCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> RdKafkaRespErrT
  -> Ptr RdKafkaTopicPartitionT
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()
type RebalanceCb'
  =  Ptr RdKafkaT -> CInt -> Ptr RdKafkaTopicPartitionT -> Ptr () -> IO ()

foreign import ccall safe "wrapper"
  mkRebalanceCb :: MkKafkaConfCb RebalanceCb'

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_rebalance_cb"
  rdKafkaConfSetRebalanceCb' :: RdKafkaSetConfCb RebalanceCb'

rdKafkaConfSetRebalanceCb :: RdKafkaConfTPtr -> RebalanceCb -> IO ()
rdKafkaConfSetRebalanceCb conf cb = do
  cb' <- mkRebalanceCb (\k err tp opq -> cb k (toEnum . fromIntegral $ err) tp opq)
  withForeignPtr conf $ \c -> rdKafkaConfSetRebalanceCb' c cb'
  return ()

--------------------------------------------------------------------------------
-- *** OffsetCommit
--------------------------------------------------------------------------------
type OffsetCommitCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> RdKafkaRespErrT
  -> Ptr RdKafkaTopicPartitionT
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()
type OffsetCommitCb'
  =  Ptr RdKafkaT -> CInt -> Ptr RdKafkaTopicPartitionT -> Ptr () -> IO ()

foreign import ccall safe "wrapper"
  mkOffsetCommitCb :: MkKafkaConfCb OffsetCommitCb'

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_offset_commit_cb"
  rdKafkaConfSetOffsetCommitCb' :: RdKafkaSetConfCb OffsetCommitCb'

rdKafkaConfSetOffsetCommitCb :: RdKafkaConfTPtr -> OffsetCommitCb -> IO ()
rdKafkaConfSetOffsetCommitCb conf cb = do
  cb' <- mkOffsetCommitCb (\k err tp opq -> cb k (toEnum . fromIntegral $ err) tp opq)
  withForeignPtr conf $ \c -> rdKafkaConfSetOffsetCommitCb' c cb'
  return ()

--------------------------------------------------------------------------------
-- *** Error
--------------------------------------------------------------------------------
type ErrorCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> CInt
  -> CString
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkErrorCb :: MkKafkaConfCb ErrorCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_error_cb"
  rdKafkaConfSetErrorCb' :: RdKafkaSetConfCb ErrorCb

rdKafkaConfSetErrorCb :: RdKafkaConfTPtr -> ErrorCb -> IO ()
rdKafkaConfSetErrorCb = rdKafkaConfSetCb mkErrorCb rdKafkaConfSetErrorCb'

--------------------------------------------------------------------------------
-- *** Throttle
--------------------------------------------------------------------------------
type ThrottleCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> CString
  -> CInt32T
  -> CInt
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkThrottleCb :: MkKafkaConfCb ThrottleCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_throttle_cb"
  rdKafkaConfSetThrottleCb' :: RdKafkaSetConfCb ThrottleCb

rdKafkaConfSetThrottleCb :: RdKafkaConfTPtr -> ThrottleCb -> IO ()
rdKafkaConfSetThrottleCb = rdKafkaConfSetCb mkThrottleCb rdKafkaConfSetThrottleCb'

--------------------------------------------------------------------------------
-- *** Log
--------------------------------------------------------------------------------
type LogCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> CInt
  -> CString
  -> CString
  -> IO ()

foreign import ccall safe "wrapper"
  mkLogCb :: MkKafkaConfCb LogCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_log_cb"
  rdKafkaConfSetLogCb' :: RdKafkaSetConfCb LogCb

rdKafkaConfSetLogCb :: RdKafkaConfTPtr -> LogCb -> IO ()
rdKafkaConfSetLogCb = rdKafkaConfSetCb mkLogCb rdKafkaConfSetLogCb'

--------------------------------------------------------------------------------
-- *** Stats
--------------------------------------------------------------------------------
type StatsCb
  =  Ptr RdKafkaT
  -- ^ pointer to Kafka message object
  -> CString
  -> CSize
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkStatsCb :: MkKafkaConfCb StatsCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_stats_cb"
  rdKafkaConfSetStatsCb' :: RdKafkaSetConfCb StatsCb

rdKafkaConfSetStatsCb :: RdKafkaConfTPtr -> StatsCb -> IO ()
rdKafkaConfSetStatsCb = rdKafkaConfSetCb mkStatsCb rdKafkaConfSetStatsCb'

--------------------------------------------------------------------------------
-- *** Socket
--------------------------------------------------------------------------------
type SocketCb
  =  CInt
  -> CInt
  -> CInt
  -> Ptr ()
  -> IO ()

foreign import ccall safe "wrapper"
  mkSocketCb :: MkKafkaConfCb SocketCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_socket_cb"
  rdKafkaConfSetSocketCb' :: RdKafkaSetConfCb SocketCb

rdKafkaConfSetSocketCb :: RdKafkaConfTPtr -> SocketCb -> IO ()
rdKafkaConfSetSocketCb = rdKafkaConfSetCb mkSocketCb rdKafkaConfSetSocketCb'

--------------------------------------------------------------------------------
-- *** Open
--------------------------------------------------------------------------------
type OpenCb
  =  CString
  -> CInt
  -> CMode
  -> Ptr ()
  -- ^ pointer to opaque object previously set by @rd_kafka_conf_set_opaque()@
  -> IO ()

foreign import ccall safe "wrapper"
  mkOpenCb :: MkKafkaConfCb OpenCb

foreign import ccall unsafe "rd_kafka.h rd_kafka_conf_set_open_cb"
  rdKafkaConfSetOpenCb' :: RdKafkaSetConfCb OpenCb

rdKafkaConfSetOpenCb :: RdKafkaConfTPtr -> OpenCb -> IO ()
rdKafkaConfSetOpenCb = rdKafkaConfSetCb mkOpenCb rdKafkaConfSetOpenCb'

--------------------------------------------------------------------------------
-- * Topic configuration
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ** Lifetime
--------------------------------------------------------------------------------

-- | Create new topic configuration object.
{#fun unsafe rd_kafka_topic_conf_new
  as ^
  {} -> `RdKafkaTopicConfTPtr' #}

-- | Duplicate/copy an existing topic configuration object.
{#fun unsafe rd_kafka_topic_conf_dup
  as ^
  { `RdKafkaTopicConfTPtr'
  } -> `RdKafkaTopicConfTPtr' #}

-- | Destroy a topic configuration object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_topic_conf_destroy"
  rdKafkaTopicConfDestroy :: FunPtr (Ptr RdKafkaTopicConfT -> IO ())

--------------------------------------------------------------------------------
-- ** Getters and setters
--------------------------------------------------------------------------------

-- | Set a topic configuration property by name. 
{#fun unsafe rd_kafka_topic_conf_set
  as ^
  { `RdKafkaTopicConfTPtr'
  -- ^ pointer to topic configuration object
  , `String'
  -- ^ property name
  , `String'
  -- ^ property value
  , id `Ptr CChar'
  -- ^ pointer to error string to fill (if not null) on error
  , fromIntegral `CSize'
  -- ^ size of error string
  } -> `RdKafkaConfResT' #}

-- | Get topic configuration property by name.
{#fun unsafe rd_kafka_topic_conf_get
  as ^
  { `RdKafkaTopicConfTPtr'
  , `String'
  , id `Ptr CChar'
  , `CSizePtr'
  } -> `RdKafkaConfResT' #}

--------------------------------------------------------------------------------
-- ** Callbacks
--------------------------------------------------------------------------------

-- | Sets the application's opaque pointer that will be passed to all topic
-- callbacks as the @rkt_opaque@ argument.
{#fun unsafe rd_kafka_topic_conf_set_opaque
  as ^
  { `RdKafkaTopicConfTPtr' 
  -- ^ pointer to Kafka topic configuration object
  , `Ptr ()'
  -- ^ pointer to be passed to callbacks
  } -> `()' id #}

--------------------------------------------------------------------------------
-- *** Partitioning
--------------------------------------------------------------------------------

type PartitionerCb
  =  Ptr RdKafkaTopicT
  -- ^ Topic paritioner pointer
  -> Ptr ()
  -- ^ keydata
  -> CSize
  -- ^ keylen
  -> CInt32T
  -- ^ partition_cnt
  -> Ptr ()
  -- ^ topic_opaque
  -> Ptr ()
  -- ^ msg_opaque
  -> IO Int

foreign import ccall safe "wrapper"
  mkPartitionerCallback :: PartitionerCb -> IO (FunPtr PartitionerCb)

-- | Producer: Set partitioner callback in provided topic conf object.
--
-- The partitioner may be called in any thread at any time, it may be called
-- multiple times for the same message/key.
-- 
-- Partitioner function constraints:
-- 
-- *   MUST NOT call any rd_kafka_*() functions except
--     @rd_kafka_topic_partition_available()@
-- *   MUST NOT block or execute for prolonged periods of time.
-- *   MUST return a value between @0@ and @partition_cnt-1@, or the special
--     @RD_KAFKA_PARTITION_UA@ value if partitioning could not be performed.
foreign import ccall unsafe "rd_kafka.h rd_kafka_topic_conf_set_partitioner_cb"
  rdKafkaTopicConfSetPartitionerCb
    :: Ptr RdKafkaTopicConfT
    -> FunPtr PartitionerCb
    -> IO ()

-- | Check if partition is available (has a leader broker).
--
-- **WARNING**: Should only be used within a partitioner function.
{#fun unsafe rd_kafka_topic_partition_available
  as ^
  { `RdKafkaTopicTPtr'
  , fromIntegral `CInt32T'
  } -> `Int' #}

-- | Random partitioner.
--
-- Will try not to return unavailable partitions.
{#fun unsafe rd_kafka_msg_partitioner_random
  as ^
  { `RdKafkaTopicTPtr'
  , castPtr `Ptr ()'
  , fromIntegral `CSize'
  , fromIntegral `CInt32T'
  , castPtr `Ptr ()'
  , castPtr `Ptr ()'
  } -> `CInt32T' fromIntegral #}

-- | Consistent partitioner.
--
-- Uses consistent hashing to map identical keys onto identical partitions.
{#fun unsafe rd_kafka_msg_partitioner_consistent
 as ^
 { `RdKafkaTopicTPtr'
 , castPtr `Ptr ()'
 , fromIntegral `CSize'
 , fromIntegral `CInt32T'
 , castPtr `Ptr ()'
 , castPtr `Ptr ()'
 } -> `CInt32T' fromIntegral #}

-- | Consistent-Random partitioner.  
-- 
-- This is the default partitioner. Uses consistent hashing to map identical
-- keys onto identical partitions, and messages without keys will be assigned
-- via the random partitioner.
{#fun unsafe rd_kafka_msg_partitioner_consistent_random
  as ^
  { `RdKafkaTopicTPtr'
  , castPtr `Ptr ()'
  , fromIntegral `CSize'
  , fromIntegral `CInt32T'
  , castPtr `Ptr ()'
  , castPtr `Ptr ()'
  } -> `CInt32T' fromIntegral #}

--------------------------------------------------------------------------------
-- * Displaying properties
--------------------------------------------------------------------------------

-- | Dump
{#fun unsafe rd_kafka_conf_dump
  as ^
  { `RdKafkaConfTPtr'
  , `CSizePtr'
  } -> `Ptr CString' id #}

{#fun unsafe rd_kafka_topic_conf_dump
  as ^
  { `RdKafkaTopicConfTPtr'
  , `CSizePtr'
  } -> `Ptr CString' id #}

{#fun unsafe rd_kafka_conf_dump_free
  as ^
  { id `Ptr CString'
  , fromIntegral `CSize'
  } -> `()' #}

{#fun unsafe rd_kafka_conf_properties_show
  as ^
  { `CFilePtr' 
  } -> `()' #}

--------------------------------------------------------------------------------
-- * Logging
--------------------------------------------------------------------------------

-- | Specify the maximum logging level produced by internal Kafka logging and
-- debugging.
{#fun unsafe rd_kafka_set_log_level
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka object
  , `Int'
  -- ^ maximum log level
  } -> `()' #}
