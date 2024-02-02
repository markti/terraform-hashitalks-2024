resource "kubernetes_manifest" "user_secrets" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "user-secrets"
      namespace = "app"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          data = [
            {
              key        = "app-insights-connection-string"
              objectName = "app-insights-connection-string"
            }
          ]
          secretName = "user"
          type       = "Opaque"
        }
      ]
      parameters = {
        usePodIdentity = "false"
        clientID       = var.workload_managed_identity_id
        keyvaultName   = var.keyvault_name
        cloudName      = ""
        objects        = <<OBJECTS
      array:
        - |
          objectName: app-insights-connection-string
          objectType: secret
          objectVersion: ""
OBJECTS
        tenantId       = data.azurerm_client_config.current.tenant_id
      }
    }
  }
}

/*

cat <<EOF | kubectl  apply -f $KCONFIG -
# This is a SecretProviderClass example using workload identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: cart-secrets # needs to be unique per namespace
  namespace: app
spec:
  provider: azure
  secretObjects:                              # [OPTIONAL] SecretObjects defines the desired state of synced Kubernetes secret objects
  - data:
    - key: redis-connection-string            # data field to populate
      objectName: redis-connection-string     # name of the mounted content to sync; this could be the object name or the object alias
    - key: redis-endpoint                     # data field to populate
      objectName: redis-endpoint              # name of the mounted content to sync; this could be the object name or the object alias
    - key: redis-username                     # data field to populate
      objectName: redis-username              # name of the mounted content to sync; this could be the object name or the object alias
    - key: app-insights-connection-string            
      objectName: app-insights-connection-string      
    secretName: cart                          # name of the Kubernetes secret object
    type: Opaque                              # type of Kubernetes secret object (for example, Opaque, kubernetes.io/tls)
  parameters:
    usePodIdentity: "false"       
    clientID: "bar"    # Setting this to use workload identity
    keyvaultName: "foo"            # Set to the name of your key vault
    cloudName: ""                             # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: redis-connection-string
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: redis-endpoint
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: redis-username
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: app-insights-connection-string
          objectType: secret
          objectVersion: ""
    tenantId: "fizz"        # The tenant ID of the key vault
EOF
*/