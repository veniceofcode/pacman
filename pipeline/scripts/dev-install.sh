echo "Connecting to the cloud database"
cat <<EOF | oc apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: dbaas-mongo-credentials-teamA
  namespace: openshift-dbaas-operator
  labels:
    atlas.mongodb.com/type: credentials
    related-to: dbaas-operator
data:
  orgId: [REDACTED base64 value]
  privateApiKey: [REDACTED base64 value]
  publicApiKey: [REDACTED base64 value]
type: Opaque
EOF
cat <<EOF | oc apply -f -
apiVersion: dbaas.redhat.com/v1alpha1
kind: DBaaSInventory
metadata:
  labels:
    related-to: dbaas-operator
    type: dbaas-vendor-service
  namespace: openshift-dbaas-operator
spec:
  credentialsRef:
    name: dbaas-mongo-credentials-teamA
    namespace: openshift-dbaas-operator
  providerRef:
    name: mongodb-atlas-registration
EOF
cat <<EOF | oc apply -f -
apiVersion: dbaas.redhat.com/v1alpha1
kind: MongoDBAtlasConnection
metadata:
  namespace: managed-pacman
spec:
  instanceID: 62a368f98381b67c94ce0fce
  inventoryRef:
    name: rhodas-rb
    namespace: redhat-dbaas-operator
status:
  conditions:
    - lastTransitionTime: '2022-06-13T13:42:48Z'
      message: ''
      reason: Ready
      status: 'True'
      type: ReadyForBinding
  connectionInfoRef:
    name: atlas-connection-cm-ks5f2
  credentialsRef:
    name: atlas-db-user-fggfj
EOF
cat <<EOF | oc apply -f -
apiVersion: binding.operators.coreos.com/v1alpha1
kind: ServiceBinding
metadata:
spec:
  application:
    group: apps
    name: fruit-shop
    resource: deployments
    version: v1
  bindAsFiles: true
  detectBindingResources: true
  services:
    - group: dbaas.redhat.com
      kind: DBaaSConnection
      name: fruit-db-5655614337
      version: v1alpha1
  secret: fruit-shop-d-fruit-db-5655614337-dbsc-7dabe40a
EOF