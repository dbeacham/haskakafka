{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.CTypes
  (
  -- * Kafka
    RdKafkaT
  , RdKafkaTPtr

  -- * Configuration
  -- ** Global
  , RdKafkaConfT
  , RdKafkaConfTPtr

  -- ** Topic
  , RdKafkaTopicConfT
  , RdKafkaTopicConfTPtr

  -- * Queue
  , RdKafkaQueueT
  , RdKafkaQueueTPtr

  -- * Message
  , RdKafkaMessageT
  , RdKafkaMessageTPtr

  -- * Enumerations
  , RdKafkaTypeT
  , RdKafkaConfResT
  , RdKafkaRespErrT
  , RdKafkaTimestampTypeT
  , RdKafkaTimestampTypeTPtr

  -- * Topic
  , RdKafkaTopicT
  , RdKafkaTopicTPtr

  -- * Topic partition
  , RdKafkaTopicPartitionT
  , RdKafkaTopicPartitionTPtr

  -- * Errors
  , RdKafkaErrDesc
  , RdKafkaErrDescPtr

  -- * Hooks
  , CInt32T
  , CInt64T
  , CSizePtr
  , CFilePtr
  ) where

import Control.Monad (liftM)
import Data.Word (Word8)
import Foreign.C.Types (CSize, CFile)
import Foreign.C.String (CString)
import Foreign (Ptr, Storable, castPtr, Int64)

#include "librdkafka/rdkafka.h"

-- Kafka handle
data RdKafkaT
{#pointer *rd_kafka_t
  as RdKafkaTPtr
  -> `RdKafkaT' #}

-- Configuration
data RdKafkaConfT
{#pointer *rd_kafka_conf_t
  as RdKafkaConfTPtr
  -> `RdKafkaConfT' #}

data RdKafkaTopicConfT
{#pointer *rd_kafka_topic_conf_t
  as RdKafkaTopicConfTPtr
  -> `RdKafkaTopicConfT' #}

-- Queue
data RdKafkaQueueT
{#pointer *rd_kafka_queue_t
  as RdKafkaQueueTPtr
  -> `RdKafkaQueueT' #}

-- Topic
data RdKafkaTopicT
{#pointer *rd_kafka_topic_t
  as RdKafkaTopicTPtr foreign
  -> RdKafkaTopicT #}

-- Topic partition
data RdKafkaTopicPartitionT = RdKafkaTopicPartitionT
  { topic'RdKafkaTopicPartitionT        :: CString
  , partition'RdKafkaTopicPartitionT    :: Int
  , offset'RdKafkaTopicPartitionT       :: Int64
  , metadata'RdKafkaTopicPartitionT     :: Ptr Word8
  , metadataSize'RdKafkaTopicPartitionT :: Int
  , opaque'RdKafkaTopicPartitionT       :: Ptr Word8
  , err'RdKafkaTopicPartitionT          :: RdKafkaRespErrT
  } deriving (Show, Eq)

instance Storable RdKafkaTopicPartitionT where
  sizeOf    _ = {#sizeof rd_kafka_topic_partition_t #}
  alignment _ = {#alignof rd_kafka_topic_partition_t #}

  peek p = RdKafkaTopicPartitionT
    <$> liftM id                      ({#get rd_kafka_topic_partition_t->topic         #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_topic_partition_t->partition     #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_topic_partition_t->offset        #} p)
    <*> liftM castPtr                 ({#get rd_kafka_topic_partition_t->metadata      #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_topic_partition_t->metadata_size #} p)
    <*> liftM castPtr                 ({#get rd_kafka_topic_partition_t->opaque        #} p)
    <*> liftM (toEnum . fromIntegral) ({#get rd_kafka_topic_partition_t->err           #} p)

  poke p x = do
    {#set rd_kafka_topic_partition_t.topic         #} p (id           $ topic'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.partition     #} p (fromIntegral $ partition'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.offset        #} p (fromIntegral $ offset'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.metadata      #} p (castPtr      $ metadata'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.metadata_size #} p (fromIntegral $ metadataSize'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.opaque        #} p (castPtr      $ opaque'RdKafkaTopicPartitionT x)
    {#set rd_kafka_topic_partition_t.err           #} p (fromIntegral . fromEnum $ err'RdKafkaTopicPartitionT x)

{#pointer *rd_kafka_topic_partition_t
  as RdKafkaTopicPartitionTPtr foreign
  -> RdKafkaTopicPartitionT #}

-- Type hooks
type CInt64T = {#type int64_t #}
type CInt32T = {#type int32_t #}

{#pointer *FILE as CFilePtr -> CFile #}
{#pointer *size_t as CSizePtr -> CSize #}

-- Enumerations
{#enum rd_kafka_type_t
  as ^ {underscoreToCase}
  deriving (Show, Eq) #}

{#enum rd_kafka_conf_res_t
  as ^ {underscoreToCase}
  deriving (Show, Eq) #}

{#enum rd_kafka_resp_err_t
  as ^ {underscoreToCase}
  deriving (Show, Eq) #}

{#enum rd_kafka_timestamp_type_t
  as ^ {underscoreToCase}
  deriving (Show, Eq) #}

{#pointer *rd_kafka_timestamp_type_t
  as RdKafkaTimestampTypeTPtr foreign
  -> RdKafkaTimestampTypeT #}

-- Message
data RdKafkaMessageT = RdKafkaMessageT
  { err'RdKafkaMessageT       :: RdKafkaRespErrT
  , topic'RdKafkaMessageT     :: Ptr RdKafkaTopicT
  , partition'RdKafkaMessageT :: Int
  , len'RdKafkaMessageT       :: Int
  , keyLen'RdKafkaMessageT    :: Int
  , offset'RdKafkaMessageT    :: Int64
  , payload'RdKafkaMessageT   :: Ptr Word8
  , key'RdKafkaMessageT       :: Ptr Word8
  , private'RdKafkaMessageT   :: Ptr ()
  }
  deriving (Show, Eq)

instance Storable RdKafkaMessageT where
  sizeOf    _ = {#sizeof rd_kafka_message_t #}
  alignment _ = {#alignof rd_kafka_message_t #}

  peek p = RdKafkaMessageT
    <$> liftM (toEnum . fromIntegral) ({#get rd_kafka_message_t->err       #} p)
    <*> liftM castPtr                 ({#get rd_kafka_message_t->rkt       #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_message_t->partition #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_message_t->len       #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_message_t->key_len   #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_message_t->offset    #} p)
    <*> liftM castPtr                 ({#get rd_kafka_message_t->payload   #} p)
    <*> liftM castPtr                 ({#get rd_kafka_message_t->key       #} p)
    <*> liftM castPtr                 ({#get rd_kafka_message_t->_private  #} p)

  poke p x = do
    {#set rd_kafka_message_t.err       #} p (fromIntegral . fromEnum $ err'RdKafkaMessageT x)
    {#set rd_kafka_message_t.rkt       #} p (castPtr                 $ topic'RdKafkaMessageT x)
    {#set rd_kafka_message_t.partition #} p (fromIntegral            $ partition'RdKafkaMessageT x)
    {#set rd_kafka_message_t.len       #} p (fromIntegral            $ len'RdKafkaMessageT x)
    {#set rd_kafka_message_t.key_len   #} p (fromIntegral            $ keyLen'RdKafkaMessageT x)
    {#set rd_kafka_message_t.offset    #} p (fromIntegral            $ offset'RdKafkaMessageT x)
    {#set rd_kafka_message_t.payload   #} p (castPtr                 $ payload'RdKafkaMessageT x)
    {#set rd_kafka_message_t.key       #} p (castPtr                 $ key'RdKafkaMessageT x)
    {#set rd_kafka_message_t._private  #} p (castPtr                 $ private'RdKafkaMessageT x)

{#pointer *rd_kafka_message_t
  as RdKafkaMessageTPtr
  -> `RdKafkaMessageT' #}

-- Errors
data RdKafkaErrDesc = RdKafkaErrDesc
  { code'RdKafkaErrDesc :: RdKafkaRespErrT
  , name'RdKafkaErrDesc :: CString
  , desc'RdKafkaErrDesc :: CString
  }
  deriving (Show, Eq)

instance Storable RdKafkaErrDesc where
  sizeOf    _ = {#sizeof rd_kafka_err_desc #}
  alignment _ = {#alignof rd_kafka_err_desc #}

  peek p = RdKafkaErrDesc
    <$> liftM (toEnum . fromIntegral) ({#get rd_kafka_err_desc->code #} p)
    <*> liftM castPtr                 ({#get rd_kafka_err_desc->name #} p)
    <*> liftM castPtr                 ({#get rd_kafka_err_desc->desc #} p)

  poke p x = do
    {#set rd_kafka_err_desc.code #} p (fromIntegral . fromEnum $ code'RdKafkaErrDesc x)
    {#set rd_kafka_err_desc.name #} p (castPtr                 $ name'RdKafkaErrDesc x)
    {#set rd_kafka_err_desc.desc #} p (castPtr                 $ desc'RdKafkaErrDesc x)

{#pointer *rd_kafka_err_desc
  as RdKafkaErrDescPtr
  -> `RdKafkaErrDesc' #}
