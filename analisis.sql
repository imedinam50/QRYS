DECLARE @runtime datetime
SET @runtime = GETDATE()

--System Requests

SELECT @runtime as runtime,
       dest.text AS [batch],
       SUBSTRING(dest.text, (der.statement_start_offset / 2) + 1, ((
       CASE 
            WHEN der.statement_end_offset < 1 THEN LEN(CONVERT(nvarchar(max), dest.text)) * 2
            ELSE der.statement_end_offset
       END - der.statement_start_offset) / 2) + 1) AS [statement],
	   deib.event_info as [input_buffer],
	   deqp.query_plan,
       der.session_id,
       request_id,
       start_time,
       status,
       command,
       DB_NAME(database_id) AS database_name,
       user_id,
       blocking_session_id,
       wait_type,
       wait_time,
       last_wait_type,
       wait_resource,
       open_transaction_count,
       open_resultset_count,
       transaction_id,
       percent_complete,
       estimated_completion_time,
       cpu_time,
       total_elapsed_time,
       scheduler_id,
       reads,
       writes,
       logical_reads,
       transaction_isolation_level,
       lock_timeout,
       deadlock_priority,
       row_count,
       prev_error,
       nest_level,
       granted_query_memory
FROM   sys.dm_exec_requests der
CROSS APPLY sys.dm_exec_sql_text (der.sql_handle) dest
CROSS APPLY sys.dm_exec_input_buffer(der.session_id, der.request_id) deib
OUTER APPLY sys.dm_exec_query_plan (der.plan_handle) deqp
WHERE  session_id <> @@SPID

--System Connections

SELECT @runtime AS runtime,
       dest.text AS [batch],
       dec.session_id,
       DB_NAME(dest.dbid),
       des.client_interface_name,
       des.client_version,
       des.host_name,
       des.login_name,
       des.original_login_name,
       des.program_name,
       des.nt_domain,
       des.nt_user_name,
       dec.most_recent_session_id,
       dec.connect_time,
       dec.net_transport,
       dec.encrypt_option,
       dec.auth_scheme,
       dec.num_reads,
       dec.num_writes,
       dec.last_read,
       dec.last_write,
       dec.client_tcp_port,
       dec.connection_id,
       dec.parent_connection_id,
       dec.protocol_type
FROM   sys.dm_exec_connections dec
INNER JOIN   sys.dm_exec_sessions des
  ON   des.session_id = dec.session_id
CROSS APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) dest
ORDER BY dec.session_id

--Locks Aquired

SELECT @runtime as runtime,
       t1.resource_type,
       db_name(resource_database_id) AS [database],
       t1.resource_associated_entity_id AS [blocked_objects],
       t1.request_mode,
       t1.request_session_id,
       t2.blocking_session_id
FROM   sys.dm_tran_locks AS t1,
       sys.dm_os_waiting_tasks AS t2
WHERE  t1.lock_owner_address = t2.resource_address

--System Waiting Tasks

SELECT @runtime as runtime,
       session_id,
       wait_duration_ms,
       resource_description
FROM   sys.dm_os_waiting_tasks
WHERE  resource_description IS NOT NULL
