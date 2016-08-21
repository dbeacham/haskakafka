{-# LANGUAGE EmptyDataDecls #-}

module Haskakafka.Internal.Configuration
  (
  -- * Global configuration
  -- ** Lifetime
    rdKafkaConfNew
  , rdKafkaConfDup
  , rdKafkaConfDestroy

  -- ** Getters and setters
  , rdKafkaConfSet
  , rdKafkaConfSetDefaultTopicConf
  , rdKafkaConfGet

  -- -- ** Callbacks
  -- , rdKafkaConfSetOpaque
  -- , rdKafkaConfSetDeliveryReportMessageCallback
  -- , rdKafkaConfSetDeliveryReportConsumeCallback
  -- , rdKafkaConfSetDeliveryReportRebalanceCallback
  -- , rdKafkaConfSetDeliveryReportOffsetCommitCallback
  -- , rdKafkaConfSetDeliveryReportErrorCallback
  -- , rdKafkaConfSetDeliveryReportThrottleCallback
  -- , rdKafkaConfSetDeliveryReportLogCallback
  -- , rdKafkaConfSetDeliveryReportStatsCallback
  -- , rdKafkaConfSetDeliveryReportSocketCallback
  -- , rdKafkaConfSetDeliveryReportOpenCallback

  -- * Topic configuration
  -- ** Lifetime
  , rdKafkaTopicConfNew
  , rdKafkaTopicConfDup
  , rdKafkaTopicConfDestroy
  --, rdKafkaTopicSetOpaque

  -- ** Getters and setters
  , rdKafkaTopicConfSet
  , rdKafkaTopicConfGet

  -- -- ** Callbacks
  -- , rdKafkaTopicConfSetOpaque
  -- , rdKafkaTopicConfSetPartitionerCallback

  -- * Displaying properties
  , rdKafkaConfDump
  , rdKafkaTopicConfDump
  , rdKafkaConfDumpFree
  , rdKafkaConfPropertiesShow

  -- * Logging
  , rdKafkaSetLogLevel
  ) where

import Foreign (Ptr, FunPtr)
import Foreign.C.String (CString)
import Foreign.C.Types (CSize, CChar)

#include "librdkafka/rdkafka.h"

{#import Haskakafka.Internal.CTypes #}

-- Global configuration
-- Lifetime

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

-- Getters and setters

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

-- Topic configuration
-- Lifetime

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

-- Displaying properties
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

{#fun unsafe rd_kafka_conf_dump_free as ^
    { id `Ptr CString'
    , fromIntegral `CSize'
    } -> `()' #}

{#fun unsafe rd_kafka_conf_properties_show as ^
    { `CFilePtr' 
    } -> `()' #}

-- | Specify the maximum logging level produced by internal Kafka logging and
-- debugging.
{#fun unsafe rd_kafka_set_log_level
  as ^
  { `RdKafkaTPtr'
  -- ^ pointer to Kafka object
  , `Int'
  -- ^ maximum log level
  } -> `()' #}
