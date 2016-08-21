{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.TopicPartitionList
  (
    rdKafkaTopicPartitionListNew
  , rdKafkaTopicPartitionListDestroy
  , rdKafkaTopicPartitionListAdd
  , rdKafkaTopicPartitionListAddRange
  , rdKafkaTopicPartitionListDel
  , rdKafkaTopicPartitionListDelByIdx
  , rdKafkaTopicPartitionListCopy
  , rdKafkaTopicPartitionListSetOffset
  , rdKafkaTopicPartitionListFind
  ) where

import Foreign (Ptr, FunPtr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Create a new list/vector topic+partition container.
{#fun unsafe rd_kafka_topic_partition_list_new
  as ^
  { `Int'
  -- ^ Initial allocated size used when the expected number of elements is
  -- known or can be estimated. Avoids reallocation and possibly relocation of
  -- the elems array.
  } -> `RdKafkaTopicPartitionListTPtr' #}

-- | Destroy a configuration object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_topic_partition_list_destroy"
  rdKafkaTopicPartitionListDestroy :: FunPtr (Ptr RdKafkaTopicPartitionListT -> IO ())

-- | 
{#fun unsafe rd_kafka_topic_partition_list_add
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `String'
  -- ^ 
  , `Int'
  -- ^ 
  } -> `RdKafkaTopicPartitionTPtr' #}

-- | 
{#fun unsafe rd_kafka_topic_partition_list_add_range
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `String'
  -- ^ 
  , `Int'
  -- ^ 
  , `Int'
  } -> `()' #}

-- | 
{#fun unsafe rd_kafka_topic_partition_list_del
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `String'
  -- ^ 
  , `Int'
  -- ^ 
  } -> `Int' #}

-- | 
{#fun unsafe rd_kafka_topic_partition_list_del_by_idx
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `Int'
  -- ^ 
  } -> `Int' #}

-- |
{#fun unsafe rd_kafka_topic_partition_list_copy
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  } -> `RdKafkaTopicPartitionListTPtr' #}

-- |
{#fun unsafe rd_kafka_topic_partition_list_set_offset
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `String'
  -- ^
  , `Int'
  -- ^
  , `Int'
  -- ^
  } -> `RdKafkaRespErrT' #}

-- |
{#fun unsafe rd_kafka_topic_partition_list_find
  as ^
  { `RdKafkaTopicPartitionListTPtr'
  -- ^ 
  , `String'
  -- ^
  , `Int'
  -- ^
  } -> `RdKafkaTopicPartitionTPtr' #}
