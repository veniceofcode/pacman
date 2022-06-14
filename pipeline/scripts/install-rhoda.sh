#!/usr/bin/env bash
echo "Installing RHODA operator"
CHANNEL=${1:-alpha}
CATALOG_SOURCE=${2:-openshift-marketplace}
oc process -f https://raw.githubusercontent.com/veniceofcode/pacman/master/pipeline/scripts/install.yaml | oc apply -f-
sleep 2
echo "Check if RHODA Operator pod is ready"
for i in {1..150}; do  # timeout after 5 minutes
  pods="$(oc get pods -n openshift-dbaas-operator --no-headers -l name=dbaas-operator 2>/dev/null |grep dbaas-operator | wc -l)"
  if [[ "${pods}" -ge 1 ]]; then
    echo -e "\nWaiting for RHODA operator pod"
    oc wait --for=condition=Ready -n openshift-dbaas-operator -l name=dbaas-operator pod --timeout=5m
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

