#!/usr/bin/env bash
echo "Installing RHODA operator"
CHANNEL=${1:-alpha}
CATALOG_SOURCE=${2:-openshift-marketplace}

cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: dbaas-operator
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/osd-addons/dbaas-operator-index@sha256:feac28aae2c33fa77122c1a0663a258b851db83beb2c33a281d6b50eab8b96e4
  displayName: DBaaS Operator
EOF
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-dbaas-operator
EOF
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: dbaas-operator
  namespace: openshift-dbaas-operator
spec:
EOF
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    operators.coreos.com/dbaas-operator.openshift-dbaas-operator: ""
  name: dbaas-operator
  namespace: openshift-dbaas-operator
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: dbaas-operator
  source: dbaas-operator
  sourceNamespace: openshift-marketplace
  startingCSV: dbaas-operator.v0.1.5
EOF
echo "Check if RHODA Operator pod is ready"
for i in {1..150}; do
  output="$(oc get catalogsource -n openshift-marketplace  dbaas-operator -o jsonpath='{.status.connectionState.lastObservedState} {"\n"}')"
  echo $output
  if [[ "${output}" -eq "READY" ]]
  then
     echo ""
     echo "successfully Installed operator!"
     exit 0
  fi
  if [[ "${i}" -eq 150 ]]; then
    echo "Timeout: operator was not created."
    exit 2
  fi
  echo -n "."
  sleep 2
done
