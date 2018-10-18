#!/bin/bash

NAMESPACE=openfaas
APP=queue-worker

POD=$(kubectl get pods -n $NAMESPACE -l app=$APP -o jsonpath="{.items[*].metadata.name}")
kubectl logs -n $NAMESPACE $POD -f
