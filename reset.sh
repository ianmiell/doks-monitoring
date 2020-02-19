#!/bin/bash
set -x
set -e
set -u
export APP_INSTANCE_NAME=monitoring
export NAMESPACE=monitoring
kubectl delete namespace "${NAMESPACE}" || true
kubectl create namespace "${NAMESPACE}"
kubens "${NAMESPACE}"
export GRAFANA_GENERATED_PASSWORD="$(echo -n 'admin' | base64)"
awk 'FNR==1 {print "---"}{print}' manifest/* | envsubst '$APP_INSTANCE_NAME $NAMESPACE $GRAFANA_GENERATED_PASSWORD' > "${APP_INSTANCE_NAME}_manifest.yaml"
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
until [[ $(kubectl get pods | grep -v NAME | grep -v 1/1 | grep -v 2/2 | wc -l | xargs) = '0' ]]
do
	echo doing
	kubectl get pods
	sleep 3
done
kubectl port-forward --namespace ${NAMESPACE} ${APP_INSTANCE_NAME}-grafana-0 3000 &
kubectl port-forward --namespace ${NAMESPACE} ${APP_INSTANCE_NAME}-prometheus-0 9090 &
kubectl port-forward --namespace ${NAMESPACE} ${APP_INSTANCE_NAME}-prometheus-0 9090 &
