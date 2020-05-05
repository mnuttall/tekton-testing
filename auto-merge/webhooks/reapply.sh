#!/bin/bash
kubectl apply -f automerge-pipeline.yaml
kubectl delete -f automerge-task.yaml
kubectl apply -f automerge-task.yaml
kubectl apply -f automerge-tt.yaml
kubectl apply -f automerge-tb.yaml