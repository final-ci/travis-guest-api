[![Build Status](https://travis-ci.org/final-ci/travis-guest-api.svg?branch=master)](https://travis-ci.org/final-ci/travis-guest-api) [![Code Climate](https://codeclimate.com/github/final-ci/travis-guest-api/badges/gpa.svg)](https://codeclimate.com/github/final-ci/travis-guest-api) [![Test Coverage](https://codeclimate.com/github/final-ci/travis-guest-api/badges/coverage.svg)](https://codeclimate.com/github/final-ci/travis-guest-api/coverage)

Guest API
=========

Provides communitacion from Guest VM to travis (to worker and database)

*This is Proof of concept ...and work in progress*

Basics of Architecutre
----------------------

[Travis-worker](https://github.com/finalci/travis-worker) do the
following:

1. starts VM
2. starts GuestAPI server
3. Forward the local port of the GuestAPI to the VM
4. set enviroment variable GUEST_API_URL in the VM and run the test.
5. ...and test can use Guest API.

Some command of GuestAPI call the callback back in travis-worker.



API endpoints
-------------
Work in progress...

  * POST /logs
  * POST steps
  * GET  steps/:testcase_uuid
  * PUT  steps/:testcase_uuid
  * POST steps/upload
  * PUT ssh     #keep_disconnected, #retry_on_disconnect
  * POST restart
  * POST finished



     curl -X POST -H "Accept: application/json" -d '{"job_id": 666, "log_message": "any text", "number": 1}' http://localhost:9292/jobs/1/logs
     curl -X POST -H "Accept: application/json" -d '{"job_id": 1, "message": "any text"}' http://localhost:8102/jobs/1/finished
     curl -X POST -H "Accept: application/json" -d '{"job_id": 2, "name": "testName", "classname": "className", "result": "success"}' http://localhost:8102/jobs/1/steps
