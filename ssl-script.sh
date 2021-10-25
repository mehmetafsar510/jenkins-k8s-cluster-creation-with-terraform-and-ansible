#! /bin/bash

docker rm -f `docker ps -q -f 'name=k8s_kube-apiserver*'`