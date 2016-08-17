{-# LANGUAGE DeriveDataTypeable #-}

module Haskakafka.InternalTypes where

import           Control.Exception
import           Data.Int
import           Data.Typeable

import           Haskakafka.InternalRdKafka
import           Haskakafka.InternalRdKafkaEnum

import qualified Data.ByteString                as BS

--
-- Pointer wrappers
--

-- | Kafka configuration object
data KafkaConf = KafkaConf RdKafkaConfTPtr deriving (Show)

-- | Kafka topic configuration object
data KafkaTopicConf = KafkaTopicConf RdKafkaTopicConfTPtr


-- | Main pointer to Kafka object, which contains our brokers
data Kafka = Kafka { kafkaPtr :: RdKafkaTPtr, _kafkaConf :: KafkaConf} deriving (Show)

-- | Main pointer to Kafka topic, which is what we consume from or produce to
data KafkaTopic = KafkaTopic
    RdKafkaTopicTPtr
    Kafka -- Kept around to prevent garbage collection
    KafkaTopicConf
--
-- Consumer
--

-- | Starting locations for a consumer
data KafkaOffset =
  -- | Start reading from the beginning of the partition
    KafkaOffsetBeginning

  -- | Start reading from the end
  | KafkaOffsetEnd

  -- | Start reading from a specific location within the partition
  | KafkaOffset Int64

  -- | Start reading from the stored offset. See
  -- <https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md librdkafka's documentation>
  -- for offset store configuration.
  | KafkaOffsetStored
  | KafkaOffsetTail Int64
  | KafkaOffsetInvalid
  deriving (Eq, Show)

-- | Represents /received/ messages from a Kafka broker (i.e. used in a consumer)
data KafkaMessage =
  KafkaMessage {
                  messageTopic     :: !String
                 -- | Kafka partition this message was received from
               ,  messagePartition :: !Int
                 -- | Offset within the 'messagePartition' Kafka partition
               , messageOffset     :: !Int64
                 -- | Contents of the message, as a 'ByteString'
               , messagePayload    :: !BS.ByteString
                 -- | Optional key of the message. 'Nothing' when the message
                 -- was enqueued without a key
               , messageKey        :: Maybe BS.ByteString
               }
  deriving (Eq, Show, Read, Typeable)

--
-- Producer
--

-- | Represents messages /to be enqueued/ onto a Kafka broker (i.e. used for a producer)
data KafkaProduceMessage =
    -- | A message without a key, assigned to 'KafkaSpecifiedPartition' or 'KafkaUnassignedPartition'
    KafkaProduceMessage
      {-# UNPACK #-} !BS.ByteString -- message payload

    -- | A message with a key, assigned to a partition based on the key
  | KafkaProduceKeyedMessage
      {-# UNPACK #-} !BS.ByteString -- message key
      {-# UNPACK #-} !BS.ByteString -- message payload
  deriving (Eq, Show, Typeable)

-- | Options for destination partition when enqueuing a message
data KafkaProducePartition =
  -- | A specific partition in the topic
    KafkaSpecifiedPartition {-# UNPACK #-} !Int  -- the partition number of the topic

  -- | A random partition within the topic
  | KafkaUnassignedPartition

--
-- Metadata
--
-- | Metadata for all Kafka brokers
data KafkaMetadata = KafkaMetadata
    {
    -- | Broker metadata
      brokers :: [KafkaBrokerMetadata]
    -- | topic metadata
    , topics  :: [Either KafkaError KafkaTopicMetadata]
    }
  deriving (Eq, Show, Typeable)

-- | Metadata for a specific Kafka broker
data KafkaBrokerMetadata = KafkaBrokerMetadata
    {
    -- | broker identifier
      brokerId   :: Int
    -- | hostname for the broker
    , brokerHost :: String
    -- | port for the broker
    , brokerPort :: Int
    }
  deriving (Eq, Show, Typeable)

-- | Metadata for a specific topic
data KafkaTopicMetadata = KafkaTopicMetadata
    {
    -- | name of the topic
      topicName       :: String
    -- | partition metadata
    , topicPartitions :: [Either KafkaError KafkaPartitionMetadata]
    } deriving (Eq, Show, Typeable)

-- | Metadata for a specific partition
data KafkaPartitionMetadata = KafkaPartitionMetadata
    {
    -- | identifier for the partition
      partitionId       :: Int

    -- | broker leading this partition
    , partitionLeader   :: Int

    -- | replicas of the leader
    , partitionReplicas :: [Int]

    -- | In-sync replica set, see <http://kafka.apache.org/documentation.html>
    , partitionIsrs     :: [Int]
    }
  deriving (Eq, Show, Typeable)

--
-- Helpers, exposed directly
--

-- | Log levels for the RdKafkaLibrary used in 'setKafkaLogLevel'
data KafkaLogLevel =
  KafkaLogEmerg | KafkaLogAlert | KafkaLogCrit | KafkaLogErr | KafkaLogWarning |
  KafkaLogNotice | KafkaLogInfo | KafkaLogDebug

instance Enum KafkaLogLevel where
   toEnum 0 = KafkaLogEmerg
   toEnum 1 = KafkaLogAlert
   toEnum 2 = KafkaLogCrit
   toEnum 3 = KafkaLogErr
   toEnum 4 = KafkaLogWarning
   toEnum 5 = KafkaLogNotice
   toEnum 6 = KafkaLogInfo
   toEnum 7 = KafkaLogDebug
   toEnum _ = undefined

   fromEnum KafkaLogEmerg = 0
   fromEnum KafkaLogAlert = 1
   fromEnum KafkaLogCrit = 2
   fromEnum KafkaLogErr = 3
   fromEnum KafkaLogWarning = 4
   fromEnum KafkaLogNotice = 5
   fromEnum KafkaLogInfo = 6
   fromEnum KafkaLogDebug = 7

-- | Any Kafka errors
data KafkaError =
    KafkaError String
  | KafkaInvalidReturnValue
  | KafkaBadSpecification String
  | KafkaResponseError RdKafkaRespErrT
  | KafkaInvalidConfigurationValue String
  | KafkaUnknownConfigurationKey String
  | KakfaBadConfiguration
    deriving (Eq, Show, Typeable)

instance Exception KafkaError
