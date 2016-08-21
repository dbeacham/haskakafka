module Haskakafka.Internal.Topic
  (
    rdKafkaTopicNew
  , rdKafkaTopicDestroy
  , rdKafkaTopicName
  , rdKafkaTopicOpaque
  ) where

import Foreign (Ptr, FunPtr)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- | Create a new topic handle with given name.
{#fun unsafe rd_kafka_topic_new
  as ^
  { `RdKafkaTPtr'
  -- ^ Kafka object pointer
  , `String'
  -- ^ Topic name
  , `RdKafkaTopicConfTPtr'
  -- ^ Pointer to topic configuration
  } -> `RdKafkaTopicTPtr' #}

-- | Destroy a configuration object.
foreign import ccall unsafe "rdkafka.h &rd_kafka_topic_destroy"
    rdKafkaTopicDestroy :: FunPtr (Ptr RdKafkaTopicT -> IO ())

-- | Return topic name.
{#fun unsafe rd_kafka_topic_name
  as ^
  { `RdKafkaTopicTPtr'
  } -> `String' #}

-- | Get the opaque pointer that was set in the topic configuration.
{#fun unsafe rd_kafka_topic_opaque
  as ^
  { `RdKafkaTopicTPtr'
  } -> `Ptr ()' id #}
