--SQL 2016
DROP EVENT SESSION [long_running_events] ON SERVER 
GO 
CREATE EVENT SESSION [long_running_events] ON SERVER 
ADD EVENT  sqlos.wait_completed (--        Occurs when there is a wait completed on a SQLOS controlled resource.  Use this event to track wait completion. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 300 
                AND((wait_type > 0 and wait_type < 22) -- LCK_ waits 
                        OR (wait_type > 31 and wait_type < 38) -- LATCH_ waits 
                        OR (wait_type > 47 AND wait_type < 54) -- PAGELATCH_ waits 
                        OR (wait_type > 63 AND wait_type < 70) -- PAGEIOLATCH_ waits 
                        OR (wait_type > 96 AND wait_type < 100) -- IO (Disk/Network) waits 
                        OR (wait_type = 110) -- RESOURCE_SEMAPHORE waits 
                        OR (wait_type = 111) -- DTC waits 
                        OR (wait_type = 112) -- OLEDB waits 
                        OR (wait_type = 116) -- SOS_WORKER waits 
                        OR (wait_type = 123) -- SOS_SCHEDULER_YIELD waits 
--                        OR (wait_type = 130) -- LOGMGR_QUEUE waits 
                        OR (wait_type > 179 AND wait_type < 182) -- FCB_REPLICA_ waits 
                        OR (wait_type = 183) -- WRITELOG waits 
--                        OR (wait_type = 190) -- LOGMGR waits 
                        OR (wait_type = 191) -- CMEMTHREAD waits 
                        OR (wait_type = 193) -- CXPACKET waits 
                        OR (wait_type = 217) -- MSQL_XP waits 
                        OR (wait_type = 218) -- MSQL_DQ waits 
                        OR (wait_type = 219) -- LOGBUFFER waits 
                        OR (wait_type = 224) -- TRACEWRITE waits 
                        OR (wait_type > 429 AND wait_type < 620) -- PREEMPTIVE_ waits 
                        OR (wait_type > 949 AND wait_type < 992) -- LCK_*_LOW_PRIORITY & LCK_*_ABORT_BLOCKERS waits 
                        OR (wait_type = 286) -- RESOURCE_SEMAPHORE_MUTEX waits 
                        OR (wait_type = 300) -- RESOURCE_SEMAPHORE_QUERY_COMPILE waits 
                ) 
        ) 
), 
ADD EVENT  sqlos.wait_info_external (--        Occurs when a SQLOS task switches to preemptive mode to execute potentially long running operations. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 500 and opcode = 1 )--miliseconds on a completed event (opcode=1) 
), 
ADD EVENT  sqlserver.sql_statement_completed (--        Occurs when a Transact-SQL statement has completed. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name--        Collects the name of the Server Principal in whose context the event is being fired 
        ) 
        WHERE ( duration > 2000000 )-- microseconds 
), 
ADD EVENT  sqlserver.sp_statement_completed (--        Occurs when a statement inside a stored procedure has completed. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 2000000 )-- microseconds 
), 
ADD EVENT  sqlserver.rpc_completed ( SET collect_data_stream=(1),collect_statement=(1) --        Occurs when a remote procedure call has completed. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 2000000 )-- microseconds 
), 
ADD EVENT  sqlserver.sql_batch_completed (--        Occurs when a Transact-SQL batch has finished executing. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 2000000 )-- microseconds 
), 
ADD EVENT  sqlserver.auto_stats (--        Occurs when index and column statistics are automatically updated. This event can be generated multiple times per statistics collection when the update is asynchronous. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 500000 )-- microseconds 
), 
--ADD EVENT  sqlserver.optimizer_timeout (--        Occurs when the optimizer times out either due to spending too much time or hitting a memory limit.  Use this event to look at all the queries that are impacted by the optimizer timeout in a particular workload. This can be very useful when tuning a particular workload. 
--        ACTION ( 
--                sqlserver.database_id,--        Collect database ID 
--                sqlserver.transaction_id,--        Collect transaction ID 
--                sqlserver.session_id,--        Collect session ID 
--                sqlserver.sql_text,--        Collect SQL text 
--                sqlserver.plan_handle,--        Collect plan handle 
--                sqlserver.client_app_name,--        Collect client application name 
--                sqlserver.client_hostname,--        Collect client hostname 
--                sqlserver.request_id,--        Collect current request ID 
--                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
--                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
--                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
--                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
--                sqlserver.server_principal_name--        Collects the name of the Server Principal in whose context the event is being fired 
--        ) 
--), 
ADD EVENT  sqlserver.xml_deadlock_report (--        Produces a deadlock report in XML format. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
), 
ADD EVENT  sqlserver.sql_transaction (--        Occurs when a SQL Server transaction begins, completes, rolls back or executes a savepoint. Use this event to monitor transaction behavior when troubleshooting applications, triggers or stored procedures. 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
        WHERE ( duration > 5000000 )-- microseconds 
), 
ADD EVENT  sqlserver.blocked_process_report (--        Occurs when a task has been blocked longer than the time that is specified by the sp_configure blocked process threshold setting. This event is not triggered by system tasks or by tasks that are waiting for non-deadlock-detectable resources. Use this event to troubleshoot blocked processes. (By default, blocked process reports are not generated.) 
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        ) 
),        
ADD EVENT  query_post_compilation_showplan (--		Occurs after a SQL statement is compiled. This event returns an XML representation of the estimated query plan that is generated when the query is compiled. Using this event can have a significant performance overhead so it should only be used when troubleshooting or monitoring specific problems for brief periods of time.
        ACTION ( 
                sqlserver.database_id,--        Collect database ID 
                sqlserver.transaction_id,--        Collect transaction ID 
                sqlserver.session_id,--        Collect session ID 
                sqlserver.sql_text,--        Collect SQL text 
                sqlserver.plan_handle,--        Collect plan handle 
                sqlserver.client_app_name,--        Collect client application name 
                sqlserver.client_hostname,--        Collect client hostname 
                sqlserver.request_id,--        Collect current request ID 
                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
				sqlserver.session_resource_group_id --        Collect current session resource group ID
        )        
        WHERE ( duration > 1000000 )-- microseconds          
)--, 
--ADD EVENT  sqlserver.inaccurate_cardinality_estimate (--        Occurs when an operator outputs significantly more rows than estimated by the Query Optimizer. Use this event to identify queries that may be using sub-optimal plans due to cardinality estimate inaccuracy. Using this event can have a significant performance overhead so it should only be used when troubleshooting or monitoring specific problems for brief periods of time. 
--        ACTION ( 
--                sqlserver.database_id,--        Collect database ID 
--                sqlserver.transaction_id,--        Collect transaction ID 
--                sqlserver.session_id,--        Collect session ID 
--                sqlserver.sql_text,--        Collect SQL text 
--                sqlserver.plan_handle,--        Collect plan handle 
--                sqlserver.client_app_name,--        Collect client application name 
--                sqlserver.client_hostname,--        Collect client hostname 
--                sqlserver.request_id,--        Collect current request ID 
--                sqlserver.transaction_sequence,--        Collect current transaction sequence number 
--                sqlserver.query_hash,--        Collect query hash. Use this to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values 
--                sqlserver.query_plan_hash,--        Collect query plan hash. Use this to identify similar query execution plans. You can use query plan hash to find the cumulative cost of queries with similar execution plans 
--                sqlserver.session_server_principal_name,--        Collects the name of the Server Principal that originated the session in which the event is being fired 
--                sqlserver.server_principal_name,--        Collects the name of the Server Principal in whose context the event is being fired 
--				sqlserver.session_resource_pool_id,--        Collect current session resource pool ID
--				sqlserver.session_resource_group_id --        Collect current session resource group ID
--        ) 
--) 
ADD TARGET package0.event_file(SET filename=N'long_running_events.xel',max_file_size=(1024),max_rollover_files=(4)) 
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=120 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF) 
GO 
ALTER EVENT SESSION [long_running_events] ON SERVER  STATE = START 
GO 
ALTER EVENT SESSION [long_running_events] ON SERVER  STATE = STOP 
GO 