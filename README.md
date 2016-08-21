# Haskakafka

Reorganising the original haskafka to

*   better understand it and C FFI
*   make understanding it easier from outside by better group C internals
*   add better documenation

Original [README](README.orig.md).

# Todo

## Version
- [X] `rd_kafka_version`
- [X] `rd_kafka_version_str`

## Errors
Depends: @RdKafkaRespErrT@

- [X] `rd_kafka_get_err_descs`

- [X] `rd_kafka_get_debug_contexts`
- [X] `rd_kafka_err2str`
- [X] `rd_kafka_err2name`

## Configuration
Depends: @RdKafkaConfT@, @RdKafkaTopicConfT@, @RdKafkaConfResT@

### Global
- [X] `rd_kafka_conf_new`
- [X] `rd_kafka_conf_destroy`
- [X] `rd_kafka_conf_dup`

- [X] `rd_kafka_conf_set`
- [X] `rd_kafka_conf_set_default_topic_conf`
- [X] `rd_kafka_conf_get`

- [X] `rd_kafka_conf_set_opaque`
- [ ] `rd_kafka_conf_set_dr_cb` (Deprecated)
- [X] `rd_kafka_conf_set_dr_msg_cb`
- [X] `rd_kafka_conf_set_consume_cb`
- [X] `rd_kafka_conf_set_rebalance_cb`
- [X] `rd_kafka_conf_set_offset_commit_cb`
- [X] `rd_kafka_conf_set_error_cb`
- [X] `rd_kafka_conf_set_throttle_cb`
- [X] `rd_kafka_conf_set_log_cb`
- [X] `rd_kafka_conf_set_stats_cb`
- [X] `rd_kafka_conf_set_socket_cb`
- [X] `rd_kafka_conf_set_open_cb`

### Topic
- [X] `rd_kafka_topic_conf_new`
- [X] `rd_kafka_topic_conf_dup`
- [X] `rd_kafka_topic_conf_destroy`
- [X] `rd_kafka_topic_conf_set`

- [X] `rd_kafka_topic_conf_set_opaque`
- [X] `rd_kafka_topic_conf_get`

### Partitioning
- [X] `rd_kafka_topic_conf_set_partitioner_cb`
- [X] `rd_kafka_topic_partition_available` (Must be called within partioning function)
- [X] `rd_kafka_msg_partitioner_random`
- [X] `rd_kafka_msg_partitioner_consistent`
- [X] `rd_kafka_msg_partitioner_consistent_random`

### Logging
- [X] `rd_kafka_set_log_level`

### Display
- [X] `rd_kafka_conf_dump`
- [X] `rd_kafka_topic_conf_dump`
- [X] `rd_kafka_conf_dump_free`
- [X] `rd_kafka_conf_properties_show`

## Topic
- [X] `rd_kafka_topic_new`
- [X] `rd_kafka_topic_destroy`
- [X] `rd_kafka_topic_name`
- [X] `rd_kafka_topic_opaque`

## Topic partition
- [X] `rd_kafka_topic_partition_list_new`
- [X] `rd_kafka_topic_partition_list_destroy`
- [X] `rd_kafka_topic_partition_list_add`
- [X] `rd_kafka_topic_partition_list_add_range`
- [X] `rd_kafka_topic_partition_list_del`
- [X] `rd_kafka_topic_partition_list_del_by_idx`
- [X] `rd_kafka_topic_partition_list_copy`
- [X] `rd_kafka_topic_partition_list_set_offset`
- [X] `rd_kafka_topic_partition_list_find`

## Kafka
- [X] `rd_kafka_new`
- [X] `rd_kafka_destroy`
- [X] `rd_kafka_name`

## Message
- [X] `rd_kafka_message_destroy`
- [X] `rd_kafka_message_errstr`
- [X] `rd_kafka_message_timestamp`

## Queue
- [X] `rd_kafka_queue_new`
- [X] `rd_kafka_queue_destroy`

## Legacy consumer API
- [ ] `rd_kafka_last_error`

### Errors
- [ ] `rd_kafka_errno`
- [ ] `rd_kafka_errno2err`

## Simple API
- [ ] `rd_kafka_consume_start`
- [ ] `rd_kafka_consume_start_queue`
- [ ] `rd_kafka_consume_stop`
- [ ] `rd_kafka_seek`
- [ ] `rd_kafka_consume`
- [ ] `rd_kafka_consume_batch`
- [ ] `rd_kafka_consume_callback`

### Queue
- [ ] `rd_kafka_consume_queue`
- [ ] `rd_kafka_consume_batch_queue`
- [ ] `rd_kafka_consume_callback_queue`

### Topic/parition offset
- [ ] `rd_kafka_offset_store`

## High level consumer API
- [X] `rd_kafka_subscribe`
- [X] `rd_kafka_unsubscribe`
- [X] `rd_kafka_subscription`
- [X] `rd_kafka_consumer_poll`
- [X] `rd_kafka_consumer_close`
- [X] `rd_kafka_assign`
- [X] `rd_kafka_assignment`
- [X] `rd_kafka_commit`
- [X] `rd_kafka_commit_message`
- [X] `rd_kafka_committed`
- [X] `rd_kafka_position`

## Metadata
- [X] `rd_kafka_metadata`
- [X] `rd_kafka_metadata_destroy`

## Producer API
- [ ] `rd_kafka_produce`
- [ ] `rd_kafka_produce_batch`

## Deprecated
- [ ] `rd_kafka_set_logger`
- [ ] `rd_kafka_log_print`
- [ ] `rd_kafka_log_syslog`

## Unsorted
- [ ] `rd_kafka_memberid`
- [ ] `rd_kafka_opaque`
- [ ] `rd_kafka_poll`
- [ ] `rd_kafka_yield`
- [ ] `rd_kafka_pause_partitions`
- [ ] `rd_kafka_resume_partitions`
- [ ] `rd_kafka_query_watermark_offsets`
- [ ] `rd_kafka_get_watermark_offsets`
- [ ] `rd_kafka_mem_free`
- [ ] `rd_kafka_list_groups`
- [ ] `rd_kafka_group_list_destroy`
- [ ] `rd_kafka_brokers_add`
- [ ] `rd_kafka_outq_len`
- [ ] `rd_kafka_dump`
- [ ] `rd_kafka_thread_cnt`
- [ ] `rd_kafka_wait_destroyed`
- [ ] `rd_kafka_poll_set_consumer`
