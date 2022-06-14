#!/usr/bin/env bash

echo "Installing RHODA operator"

CHANNEL=${1:-alpha}
CATALOG_SOURCE=${2:-openshift-marketplace}

cat <<-EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-dbaas-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: dbaas-operator
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/osd-addons/dbaas-operator-index@sha256:feac28aae2c33fa77122c1a0663a258b851db83beb2c33a281d6b50eab8b96e4
  displayName: DBaaS Operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: dbaas-operator
  namespace: openshift-dbaas-operator
EOF
cat <<-EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: dbaas-operator
  namespace: openshift-dbaas-operator
spec:
  source: $CATALOG_SOURCE
  sourceNamespace: openshift-marketplace
  name: dbaas-operator
  installPlanApproval: Automatic
  channel: $CHANNEL
  startingCSV: dbaas-operator.v0.1.5
---
EOF
echo "Check if RHODA Operator pod is ready"
for i in {1..150}; do  # timeout after 5 minutes
  pods="$(oc get pods -n openshift-marketplace --no-headers -l name=dbaas-operator 2>/dev/null |grep dbaas-operator | wc -l)"
  if [[ "${pods}" -ge 1 ]]; then
    echo -e "\nWaiting for RHODA operator pod"
    oc wait --for=condition=Ready -n openshift-marketplace -l name=dbaas-operator pod --timeout=5m
    retval=$?
    if [[ "${retval}" -gt 0 ]]; then exit "${retval}"; else break; fi
  fi
  if [[ "${i}" -eq 150 ]]; then
    echo "Timeout: pod was not created."
    exit 2
  fi
  echo -n "."
  sleep 2
done
echo "Openshift Database Access Operator is installed and Running!"


echo "Start Installation of Knative Serving"
sleep 20

for i in {1..150}; do
  output="$(oc get knativeserving.operator.knative.dev/knative-serving -n knative-serving --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}' | grep True | wc -l)"
  if [[ "${output}" -eq "3" ]]
  then
     echo ""
     echo "successfully Installed Knative Serving for Serverless operator!"
     exit 0
  fi
  if [[ "${i}" -eq 150 ]]; then
    echo "Timeout: pod was not created."
    exit 2
  fi
  echo -n "."
  sleep 2
done
