#! /bin/sh

kubectl config set-cluster fermo --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-context fermo --cluster=fermo
kubectl config set-credentials user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-context fermo --user=user
kubectl config use-context fermo