#!/bin/bash

for i in {1..10};
do
  echo "calling async callback $i (deployed) ";
  curl -X POST 'http://localhost:31112/async-function/foo' -H 'X-Callback-Url:http://gateway.openfaas:8080/function/bar' --data '{"workerId":"worker-0.9176798083869617", "jobId":12}'
  sleep 1;
done

echo faas remove -f stack.yml --gateway 127.0.0.1:31112
faas remove -f stack.yml --gateway 127.0.0.1:31112

for i in {1..3};
do
  echo "calling async callback $i (removing)";
  curl -X POST 'http://localhost:31112/async-function/foo' -H 'X-Callback-Url:http://gateway.openfaas:8080/function/bar' --data '{"workerId":"worker-0.9176798083869617", "jobId":12}'
  sleep 1;
done

echo faas deploy -f stack.yml --gateway 127.0.0.1:31112
faas deploy -f stack.yml --gateway 127.0.0.1:31112
## sometimes this deploy does not actually work since it could still be removing...
## this is where the crash should start

for i in {1..10};
do
  echo "calling async callback $i (redeploying)";
  curl -X POST 'http://localhost:31112/async-function/foo' -H 'X-Callback-Url:http://gateway.openfaas:8080/function/bar' --data '{"workerId":"worker-0.9176798083869617", "jobId":12}'
  sleep 2;
done

echo faas deploy -f stack.yml --gateway 127.0.0.1:31112
faas deploy -f stack.yml --gateway 127.0.0.1:31112

for i in {1..10};
do
  echo "calling async callback $i (redeploying)";
  curl -X POST 'http://localhost:31112/async-function/foo' -H 'X-Callback-Url:http://gateway.openfaas:8080/function/bar' --data '{"workerId":"worker-0.9176798083869617", "jobId":12}'
  sleep 2;
done
