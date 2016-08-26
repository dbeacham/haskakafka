module Haskakafka.Internal.ConfigurationAPI
  (
    newConfiguration
  , Configuration(..)
  ) where

#include "librdkafka/rdkafka.h"

import Data.Map as M
import Data.ByteString
import Control.Monad (forM)
import Foreign.Ptr (FunPtr, Ptr)
import Foreign.ForeignPtr (ForeignPtr, newForeignPtr, withForeignPtr)
import Foreign.Storable (Storable)
import Foreign.Marshal.Alloc (allocaBytes)

{#import Haskakafka.Internal.CTypes #}

--------------------------------------------------------------------------------
-- * Global configuration
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ** Lifetime
--------------------------------------------------------------------------------

-- | Destroy a configuration object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_conf_destroy"
  rd_kafka_conf_destroy :: FunPtr (Ptr RdKafkaConfT -> IO ())

data ConfigurationSettings a = ConfigurationSettings
    { _configurationProperties             :: M.Map ByteString ByteString
    -- , _configurationDeliveryReportCallback :: Maybe (DeliveryReportCallback a)
    -- , _configurationConsumeCallback        :: Maybe (ConsumeCallback a)
    -- , _configurationRebalanceCallback      :: Maybe (RebalanceCallback a)
    -- , _configurationOffsetCommitCallback   :: Maybe (OffsetCommitCallback a)
    -- , _configurationErrorCallback          :: Maybe (ErrorCallback a)
    -- , _configurationThrottleCallback       :: Maybe (ThrottleCallback a)
    -- , _configurationLogCallback            :: Maybe (LogCallback a)
    -- , _configurationStatsCallback          :: Maybe (StatsCallback a)
    -- , _configurationSocketCallback         :: Maybe (SocketCallback a)
    -- , _configurationOpenCallback           :: Maybe (OpenCallback a)
    }

data ConfigurationError = ConfigurationError
    { _configurationErrorProperyName      :: ByteString
    , _configurationErrorProperyValue     :: ByteString
    , _configurationErrorErrorCode        :: RdKafkaConfResT
    , _configurationErrorErrorDescription :: ByteString
    }

newtype Configuration a = Configuration (ForeignPtr RdKafkaConfT)
newtype Handle a = Handle (ForeignPtr RdKafkaT)

mkConfiguration :: IO (Configuration a)
mkConfiguration =
    {# call unsafe rd_kafka_conf_new #}
    >>= newForeignPtr rd_kafka_conf_destroy
    >>= return . Configuration

dupConfiguration :: Configuration a -> IO (Configuration a)
dupConfiguration (Configuration confPtr) =
    withForeignPtr confPtr $ \ptr -> do
        {# call rd_kafka_conf_dup #} ptr
        >>= newForeignPtr rd_kafka_conf_destroy
        >>= return . Configuration

withConfiguration :: Configuration a -> (Ptr RdKafkaConfT -> IO b) -> IO b
withConfiguration (Configuration confPtr) = withForeignPtr confPtr

newConfiguration
    :: Storable a
    => ConfigurationSettings a
    -> IO (Configuration a, M.Map ByteString ConfigurationError)
newConfiguration settings = do
    conf <- mkConfiguration
    errs <- withConfiguration conf $ \p ->
        sequenceA $ M.mapMaybeWithKey 
            (setConfigurationProperty (256::Int) p k v)
            (_configurationProperties settings)

    return (conf, errs)

setConfigurationProperty
    :: Integral a
    => a
    -> Ptr RdKafkaConfT
    -> ByteString
    -> ByteString
    -> IO (Maybe ConfigurationError)
setConfigurationProperty szErrBuf confPtr nm vl =
    allocaBytes (fromIntegral szErrBuf) $ \errBufPtr ->
    useAsCString nm $ \nmPtr ->
    useAsCString vl $ \vlPtr -> do
    ret <- {# call rd_kafka_conf_set #} confPtr nmPtr vlPtr errBufPtr (fromIntegral szErrBuf)
    case (toEnum . fromIntegral) ret of
        RdKafkaConfOk -> return Nothing
        errCode       -> do
            errDesc <- packCString errBufPtr
            return . Just $ ConfigurationError nm vl errCode errDesc

--mkHandle :: Configuration a -> 
--mkHandle 
--    {# call unsafe rd_kafka_conf_new #}
--    >>= newForeignPtr rd_kafka_conf_destroy
--    >>= return . Configuration
--newHandle
--    :: Storable a
--    -> Configuration a
--    -> RdKafkaType
--    -> 
--newHandle (Configuration confPtr) kafkaType
--    confPtr <- mkDuplicateConf
--    errs <- withConfiguration conf $ \p ->
--        sequenceA $ M.mapMaybeWithKey 
--            (\k v -> sequenceA (setConfigurationProperty (256::Int) p k v))
--            (_configurationProperties conf)
--
--    return (confPtr, errs)
-- withKakaConsumer
--     :: Storable a
--     -> HandleConfiguration a
--     -> ([ConfigurationError] -> Handle -> IO ())
--     -> IO ()
-- withKakaConsumer = undefined
