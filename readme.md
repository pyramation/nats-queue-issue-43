Code for issue https://github.com/openfaas/nats-queue-worker/issues/43

# steps to reproduce

### environment 

* Using docker for mac kubernetes

* using `--gateway 127.0.0.1:31112` external, and `gateway.openfaas:8080` for internal. 

* I'm also not using a Always pull policy, so you may need to look inside of `scripts/` and adjust to a prefix and publish an image and update the `stack.yml` to get this to run

### Build the functions and deploy them

```
faas remove -f stack.yml --gateway 127.0.0.1:31112
faas build -f stack.yml
faas deploy -f stack.yml --gateway 127.0.0.1:31112
```

### log queue worker

Open another shell, and log the queue worker

```
./scripts/log-queue-worker.sh
```

### Crash

Go back to the first shell and run the script that should crash the `queue-worker`:

```
./scripts/crash.sh
```

** potentially try running the crash script twice if it doesn't work the first time

### Un-crash the worker

Depending on your system, the deploy could have worked. For mine, it seems as though there is a lag to removal (probably k8s Termination), so the call to `deploy` returns a 500 code. If that's the case, wait a while, then manually `deploy` again to get functions up, and the nats queue should go back up.

```
faas deploy -f stack.yml --gateway 127.0.0.1:31112
```

And you'll have to tail the queue-worker again, you should eventually see it go back up.

```
./scripts/log-queue-worker.sh
```

### Teardown

```
faas remove -f stack.yml --gateway 127.0.0.1:31112
```

## notes on crash

During the `remove` nothing bad happens, however, right around the time the 2nd `deploy` happens, this happens (probably because it may still be removing?)

```
Unexpected status: 500, message: object is being deleted: deployments.extensions "bar" already exists

Deploying: foo.

Unexpected status: 500, message: object is being deleted: deployments.extensions "foo" already exists
```

My gut tells me it's something due to the lag of k8s when the deployment is attempted, but the removal has not completed. Or potentially some parts of the k8s are setup but others are not.

## full log from crash script

```
$ ./scripts/02-crash.sh
calling async callback 1 (deployed)
calling async callback 2 (deployed)
calling async callback 3 (deployed)
calling async callback 4 (deployed)
calling async callback 5 (deployed)
calling async callback 6 (deployed)
calling async callback 7 (deployed)
calling async callback 8 (deployed)
calling async callback 9 (deployed)
calling async callback 10 (deployed)
Deleting: foo.
Removing old function.
Deleting: bar.
Removing old function.
calling async callback 1 (removing)
calling async callback 2 (removing)
calling async callback 3 (removing)
calling async callback 4 (removing)
calling async callback 5 (removing)
calling async callback 6 (removing)
calling async callback 7 (removing)
calling async callback 8 (removing)
calling async callback 9 (removing)
calling async callback 10 (removing)
calling async callback 11 (removing)
calling async callback 12 (removing)
calling async callback 13 (removing)
calling async callback 14 (removing)
calling async callback 15 (removing)
Deploying: bar.

Unexpected status: 500, message: object is being deleted: deployments.extensions "bar" already exists

Deploying: foo.

Unexpected status: 500, message: object is being deleted: deployments.extensions "foo" already exists

Function 'bar' failed to deploy with status code: 500
Function 'foo' failed to deploy with status code: 500
calling async callback 1 (redeploying)
calling async callback 2 (redeploying)
calling async callback 3 (redeploying)
calling async callback 4 (redeploying)
calling async callback 5 (redeploying)
calling async callback 6 (redeploying)
calling async callback 7 (redeploying)
calling async callback 8 (redeploying)
calling async callback 9 (redeploying)
calling async callback 10 (redeploying)
Deploying: foo.

Deployed. 202 Accepted.
URL: http://127.0.0.1:31112/function/foo

Deploying: bar.

Deployed. 202 Accepted.
URL: http://127.0.0.1:31112/function/bar

calling async callback 1 (redeploying)
calling async callback 2 (redeploying)
calling async callback 3 (redeploying)
calling async callback 4 (redeploying)
calling async callback 5 (redeploying)
calling async callback 6 (redeploying)
calling async callback 7 (redeploying)
calling async callback 8 (redeploying)
calling async callback 9 (redeploying)
calling async callback 10 (redeploying)
```

### log from queue-worker

```
Callback to: http://gateway.openfaas:8080/function/bar
Posted result: 200
Error with AddBasicAuth : Unable to read basic auth: invalid SecretMountPath specified for reading secrets
Posting report - 200
[#11] Received on [faas-request]: 'sequence:132 subject:"faas-request" data:"{\"Header\":{\"Accept\":[\"*/*\"],\"Content-Length\":[\"52\"],\"Content-Type\":[\"application/x-www-form-urlencoded\"],\"User-Agent\":[\"curl/7.54.0\"],\"X-Call-Id\":[\"de92184d-105d-4260-9eb8-496ece782baa\"],\"X-Callback-Url\":[\"http://gateway.openfaas:8080/function/bar\"],\"X-Start-Time\":[\"1539900637321942500\"]},\"Host\":\"localhost:31112\",\"Body\":\"eyJ3b3JrZXJJZCI6Indvcmtlci0wLjkxNzY3OTgwODM4Njk2MTciLCAiam9iSWQiOjEyfQ==\",\"Method\":\"POST\",\"Path\":\"\",\"QueryString\":\"\",\"Function\":\"foo\",\"CallbackUrl\":{\"Scheme\":\"http\",\"Opaque\":\"\",\"User\":null,\"Host\":\"gateway.openfaas:8080\",\"Path\":\"/function/bar\",\"RawPath\":\"\",\"ForceQuery\":false,\"RawQuery\":\"\",\"Fragment\":\"\"}}" timestamp:1539900637324999700 '
Request for foo.
Wrote 0 Bytes
Callback to: http://gateway.openfaas:8080/function/bar
200 OK
Posted result: 200
Error with AddBasicAuth : Unable to read basic auth: invalid SecretMountPath specified for reading secrets
Posting report - 200
Request for foo.
[#12] Received on [faas-request]: 'sequence:133 subject:"faas-request" data:"{\"Header\":{\"Accept\":[\"*/*\"],\"Content-Length\":[\"52\"],\"Content-Type\":[\"application/x-www-form-urlencoded\"],\"User-Agent\":[\"curl/7.54.0\"],\"X-Call-Id\":[\"f3d9d551-c093-44c2-bc3d-14a035de1e0a\"],\"X-Callback-Url\":[\"http://gateway.openfaas:8080/function/bar\"],\"X-Start-Time\":[\"1539900638759159000\"]},\"Host\":\"localhost:31112\",\"Body\":\"eyJ3b3JrZXJJZCI6Indvcmtlci0wLjkxNzY3OTgwODM4Njk2MTciLCAiam9iSWQiOjEyfQ==\",\"Method\":\"POST\",\"Path\":\"\",\"QueryString\":\"\",\"Function\":\"foo\",\"CallbackUrl\":{\"Scheme\":\"http\",\"Opaque\":\"\",\"User\":null,\"Host\":\"gateway.openfaas:8080\",\"Path\":\"/function/bar\",\"RawPath\":\"\",\"ForceQuery\":false,\"RawQuery\":\"\",\"Fragment\":\"\"}}" timestamp:1539900638767709600 '
Post http://foo.openfaas-fn.svc.cluster.local:8080/: dial tcp 10.105.147.103:8080: i/o timeout
Callback to: http://gateway.openfaas:8080/function/bar
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x69b878]

goroutine 19 [running]:
main.postResult(0xc4200719e0, 0x0, 0x0, 0x0, 0x0, 0xc420302000, 0x29, 0xc42025b980, 0x24, 0x0, ...)
        /go/src/github.com/openfaas/nats-queue-worker/main.go:239 +0xb8
main.main.func1(0xc4202ec360)
        /go/src/github.com/openfaas/nats-queue-worker/main.go:122 +0x8ba
github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats-streaming.(*conn).processMsg(0xc4200f6380, 0xc420120870)
        /go/src/github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats-streaming/stan.go:751 +0x26f
github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats-streaming.(*conn).(github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats-streaming.processMsg)-fm(0xc420120870)
        /go/src/github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats-streaming/sub.go:228 +0x34
github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats.(*Conn).waitForMsgs(0xc4200ac500, 0xc42015c240)
        /go/src/github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats/nats.go:1652 +0x24a
created by github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats.(*Conn).subscribe
        /go/src/github.com/openfaas/nats-queue-worker/vendor/github.com/nats-io/go-nats/nats.go:2374 +0x4de
```