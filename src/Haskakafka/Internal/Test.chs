{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Test
  (
  -- * Lifetime
    rd_kafka_pause_partitions
  , rdKafkaPausePartitions
  ) where

import Foreign as C2HSImp
import Foreign (Ptr)

#include "librdkafka/rdkafka.h"
-- {# context lib="rdkafka" #}

{#import Haskakafka.Internal.CTypes #}

-- | Create new kafka object.
rdKafkaPausePartitions :: Ptr RdKafkaT -> Ptr (RdKafkaTopicPartitionListT) -> IO RdKafkaRespErrT
rdKafkaPausePartitions k ktp =
  {#call unsafe rd_kafka_pause_partitions #} k ktp
  >>= return . toEnum . fromIntegral 
