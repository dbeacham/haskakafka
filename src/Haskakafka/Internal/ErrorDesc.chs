module Haskakafka.Internal.ErrorDesc
  ( rdKafkaVersion
  , rdKafkaVersionStr
  ) where

#include "librdkafka/rdkafka.h"

{#fun pure unsafe rd_kafka_version as ^
    {} -> `Int' #}

{#fun pure unsafe rd_kafka_version_str as ^
    {} -> `String' #}

