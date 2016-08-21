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
  , RdKafkaTypeT(..)
  , RdKafkaConfResT(..)
  , RdKafkaRespErrT(..)
  , RdKafkaTimestampTypeT(..)
  , RdKafkaTimestampTypeTPtr

  -- * Metadata
  , RdKafkaMetadataT(..)
  , RdKafkaMetadataTPtr
  , RdKafkaMetadataBrokerT(..)
  , RdKafkaMetadataBrokerTPtr
  , RdKafkaMetadataTopicT(..)
  , RdKafkaMetadataTopicTPtr
  , RdKafkaMetadataPartitionT(..)
  , RdKafkaMetadataPartitionTPtr

  -- * Topic
  , RdKafkaTopicT
  , RdKafkaTopicTPtr

  -- * Topic partition
  , RdKafkaTopicPartitionT
  , RdKafkaTopicPartitionTPtr

  -- * Topic partition list
  , RdKafkaTopicPartitionListT
  , RdKafkaTopicPartitionListTPtr

  -- * Errors
  , RdKafkaErrDesc(..)
  , RdKafkaErrDescPtr

  -- * Hooks
  , CInt32T
  , CInt64T
  , CSizePtr
  , CFilePtr
  ) where

import Control.Monad (liftM)
import Data.Word (Word8)
import Foreign.C.Types (CSize, CFile, CInt)
import Foreign.C.String (CString)
import Foreign (Ptr, Storable, peek, poke, castPtr, Int64)

#include "librdkafka/rdkafka.h"

-- Kafka handle
data RdKafkaT
{#pointer *rd_kafka_t
  as RdKafkaTPtr
  foreign
  -> `RdKafkaT' #}

-- Configuration
data RdKafkaConfT
{#pointer *rd_kafka_conf_t
  as RdKafkaConfTPtr
  foreign
  -> `RdKafkaConfT' #}

data RdKafkaTopicConfT
{#pointer *rd_kafka_topic_conf_t
  as RdKafkaTopicConfTPtr
  foreign
  -> `RdKafkaTopicConfT' #}

-- Queue
data RdKafkaQueueT
{#pointer *rd_kafka_queue_t
  as RdKafkaQueueTPtr
  foreign
  -> `RdKafkaQueueT' #}

-- Topic
data RdKafkaTopicT
{#pointer *rd_kafka_topic_t
  as RdKafkaTopicTPtr foreign
  -> RdKafkaTopicT #}

-- Metadata
data RdKafkaMetadataBrokerT = RdKafkaMetadataBrokerT
  { id'RdKafkaMetadataBrokerT  :: Int
  , host'RdKafkaMetadataBrokerT :: CString
  , port'RdKafkaMetadataBrokerT :: Int
  } deriving (Show, Eq)

{#pointer
    *rd_kafka_metadata_broker_t
  as RdKafkaMetadataBrokerTPtr
  -> RdKafkaMetadataBrokerT #}

instance Storable RdKafkaMetadataBrokerT where
  sizeOf    _ = {#sizeof rd_kafka_metadata_broker_t  #}
  alignment _ = {#alignof rd_kafka_metadata_broker_t #}

  peek p = RdKafkaMetadataBrokerT
    <$> liftM fromIntegral ({#get rd_kafka_metadata_broker_t->id   #} p)
    <*> liftM id           ({#get rd_kafka_metadata_broker_t->host #} p)
    <*> liftM fromIntegral ({#get rd_kafka_metadata_broker_t->port #} p)

  poke = undefined

data RdKafkaMetadataPartitionT = RdKafkaMetadataPartitionT
  { id'RdKafkaMetadataPartitionT         :: Int
  , err'RdKafkaMetadataPartitionT        :: RdKafkaRespErrT
  , leader'RdKafkaMetadataPartitionT     :: Int
  , replicaCnt'RdKafkaMetadataPartitionT :: Int
  , replicas'RdKafkaMetadataPartitionT   :: Ptr CInt32T
  , isrCnt'RdKafkaMetadataPartitionT     :: Int
  , isrs'RdKafkaMetadataPartitionT       :: Ptr CInt32T
  } deriving (Show, Eq)

{#pointer *rd_kafka_metadata_partition_t
  as RdKafkaMetadataPartitionTPtr
  -> RdKafkaMetadataPartitionT #}

instance Storable RdKafkaMetadataPartitionT where
  sizeOf    _ = {#sizeof  rd_kafka_metadata_partition_t #}
  alignment _ = {#alignof rd_kafka_metadata_partition_t #}

  peek p = RdKafkaMetadataPartitionT
    <$> liftM fromIntegral            ({#get rd_kafka_metadata_partition_t->id          #} p)
    <*> liftM (toEnum . fromIntegral) ({#get rd_kafka_metadata_partition_t->err         #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_metadata_partition_t->leader      #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_metadata_partition_t->replica_cnt #} p)
    <*> liftM castPtr                 ({#get rd_kafka_metadata_partition_t->replicas    #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_metadata_partition_t->isr_cnt     #} p)
    <*> liftM castPtr                 ({#get rd_kafka_metadata_partition_t->isrs        #} p)

  poke = undefined

data RdKafkaMetadataTopicT = RdKafkaMetadataTopicT
  { topic'RdKafkaMetadataTopicT        :: CString
  , partitionCnt'RdKafkaMetadataTopicT :: Int
  , partitions'RdKafkaMetadataTopicT   :: Ptr RdKafkaMetadataPartitionT
  , err'RdKafkaMetadataTopicT          :: RdKafkaRespErrT
  } deriving (Show, Eq)

{#pointer *rd_kafka_metadata_topic_t
  as RdKafkaMetadataTopicTPtr
  -> RdKafkaMetadataTopicT #}

instance Storable RdKafkaMetadataTopicT where
  sizeOf    _ = {#sizeof  rd_kafka_metadata_topic_t #}
  alignment _ = {#alignof rd_kafka_metadata_topic_t #}

  peek p = RdKafkaMetadataTopicT
    <$> liftM id                      ({#get rd_kafka_metadata_topic_t->topic         #} p)
    <*> liftM fromIntegral            ({#get rd_kafka_metadata_topic_t->partition_cnt #} p)
    <*> liftM castPtr                 ({#get rd_kafka_metadata_topic_t->partitions    #} p)
    <*> liftM (toEnum . fromIntegral) ({#get rd_kafka_metadata_topic_t->err           #} p)

  poke = undefined

data RdKafkaMetadataT = RdKafkaMetadataT
  { brokerCnt'RdKafkaMetadataT    :: Int
  , brokers'RdKafkaMetadataT      :: RdKafkaMetadataBrokerTPtr
  , topicCnt'RdKafkaMetadataT     :: Int
  , topics'RdKafkaMetadataT       :: RdKafkaMetadataTopicTPtr
  , origBrokerId'RdKafkaMetadataT :: CInt32T
  } deriving (Show, Eq)

{#pointer *rd_kafka_metadata_t
  as RdKafkaMetadataTPtr
  foreign
  -> RdKafkaMetadataT #}

instance Storable RdKafkaMetadataT where
  sizeOf    _ = {#sizeof  rd_kafka_metadata_t #}
  alignment _ = {#alignof rd_kafka_metadata_t #}

  peek p = RdKafkaMetadataT
    <$> liftM fromIntegral ({#get rd_kafka_metadata_t->broker_cnt     #} p)
    <*> liftM castPtr      ({#get rd_kafka_metadata_t->brokers        #} p)
    <*> liftM fromIntegral ({#get rd_kafka_metadata_t->topic_cnt      #} p)
    <*> liftM castPtr      ({#get rd_kafka_metadata_t->topics         #} p)
    <*> liftM fromIntegral ({#get rd_kafka_metadata_t->orig_broker_id #} p)

  poke = undefined

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

-- Topic partition lists
data RdKafkaTopicPartitionListT = RdKafkaTopicPartitionListT
  { cnt'RdKafkaTopicPartitionListT   :: Int
  , size'RdKafkaTopicPartitionListT  :: Int
  , elems'RdKafkaTopicPartitionListT :: Ptr RdKafkaTopicPartitionT
  } deriving (Show, Eq)

{#pointer *rd_kafka_topic_partition_list_t
  as RdKafkaTopicPartitionListTPtr
  foreign
  -> RdKafkaTopicPartitionListT #}

instance Storable RdKafkaTopicPartitionListT where
  sizeOf    _ = {#sizeof  rd_kafka_topic_partition_list_t #}
  alignment _ = {#alignof rd_kafka_topic_partition_list_t #}

  peek p = RdKafkaTopicPartitionListT
    <$> liftM fromIntegral ({#get rd_kafka_topic_partition_list_t->cnt   #} p)
    <*> liftM fromIntegral ({#get rd_kafka_topic_partition_list_t->size  #} p)
    <*> liftM castPtr      ({#get rd_kafka_topic_partition_list_t->elems #} p)

  poke p x = do
    {#set rd_kafka_topic_partition_list_t.cnt   #} p (fromIntegral $ cnt'RdKafkaTopicPartitionListT x)
    {#set rd_kafka_topic_partition_list_t.size  #} p (fromIntegral $ size'RdKafkaTopicPartitionListT x)
    {#set rd_kafka_topic_partition_list_t.elems #} p (castPtr      $ elems'RdKafkaTopicPartitionListT x)

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

instance Storable RdKafkaRespErrT where
  sizeOf    _ = {#sizeof rd_kafka_resp_err_t #}
  alignment _ = {#alignof rd_kafka_resp_err_t #}

  peek p = do
    cInt <- peek (castPtr p) :: IO CInt
    return . toEnum . fromIntegral $ cInt

  poke p x = let cInt = (fromIntegral . fromEnum) x :: CInt
             in poke (castPtr p) cInt

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
