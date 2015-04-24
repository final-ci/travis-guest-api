Guest API
=========

Provides communitacion from Guest VM to travis (to worker and database)

API:
  * POST jobs/:job_id/log

  * POST /jobs/:job_id/testcases
  * GET  /jobs/:job_id/testcases/:testcase_uuid
  * PUT  /jobs/:job_id/testcases/:testcase_uuid

  * POST /jobs/:job_id/testcases/upload

  * PUT /jobs/:job_id/ssh     #keep_disconnected, #retry_on_disconnect

  * POST /jobs/:job_id/restart

  * POST /jobs/:job_id/finished




     curl -X POST -H "Accept: application/json" -d '{"job_id": 666, "log_message": "any text", "number": 1}' http://localhost:9292/jobs/1/logs
     curl -X POST -H "Accept: application/json" -d '{"job_id": 666, "test_case_description": "MY TESTCASE", "description": "MY STEP", "result": "success"}' http://localhost:9292/jobs/1/step_results
