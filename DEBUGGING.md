
Steps from bash:

     curl -H "Content-Type: application/json" -X POST -d '{"name":"step1", "classname":"testcase1"}' localhost:9292/api/v2/jobs/123/steps
     #expecting that returns uuid: 9ea79f22-c6b2-4813-af31-687b19c64a93
     curl http://localhost:9292/api/v2/jobs/123/steps/9ea79f22-c6b2-4813-af31-687b19c64a93
     curl -H "Content-Type: application/json" -X PUT -d '{"result": "failed"}' http://localhost:9292/api/v2/jobs/123/steps/9ea79f22-c6b2-4813-af31-687b19c64a93
     curl http://localhost:9292/api/v2/jobs/123/steps/9ea79f22-c6b2-4813-af31-687b19c64a93
