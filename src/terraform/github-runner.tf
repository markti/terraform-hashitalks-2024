/*
resource "azapi_resource" "github_custom_runner" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "string"
  location  = "string"
  parent_id = "string"
  identity {
    type         = "string"
    identity_ids = []
  }
  body = jsonencode({
    properties = {
      configuration = {
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            maxExecutions   = 10
            minExecutions   = 0
            pollingInterval = 30
            rules = [
              {
                auth = [
                  {
                    secretRef        = "personalAccessToken=personal-access-token"
                    triggerParameter = "string"
                  }
                ]
                metadata = {
                  githubAPIURL              = "https://api.github.com"
                  owner                     = "$REPO_OWNER"
                  runnerScope               = "repo"
                  repos                     = "$REPO_NAME"
                  targetWorkflowQueueLength = "1"
                }
                name = "github-runner"
                type = "github-runner"
              }
            ]
          }
        }
        registries = [
          {
            identity          = "string"
            passwordSecretRef = "string"
            server            = "string"
            username          = "string"
          }
        ]
        replicaRetryLimit = 0
        replicaTimeout    = 1800
        secrets = [
          {
            name  = "personal-access-token"
            value = "$GITHUB_PAT"
          }
        ]
        triggerType = "string"
      }
      environmentId = "string"
      template = {
        containers = [
          {
            args = [
              "string"
            ]
            command = [
              "string"
            ]
            env = [
              {
                name      = "string"
                secretRef = "string"
                value     = "string"
              }
            ]
            image = "string"
            name  = "string"
            probes = [
              {
                failureThreshold = int
                httpGet = {
                  host = "string"
                  httpHeaders = [
                    {
                      name  = "string"
                      value = "string"
                    }
                  ]
                  path   = "string"
                  port   = int
                  scheme = "string"
                }
                initialDelaySeconds = int
                periodSeconds       = int
                successThreshold    = int
                tcpSocket = {
                  host = "string"
                  port = int
                }
                terminationGracePeriodSeconds = int
                timeoutSeconds                = int
                type                          = "string"
              }
            ]
            resources = {
              cpu    = "decimal-as-string"
              memory = "string"
            }
            volumeMounts = [
              {
                mountPath  = "string"
                subPath    = "string"
                volumeName = "string"
              }
            ]
          }
        ]
        initContainers = [
          {
            args = [
              "string"
            ]
            command = [
              "string"
            ]
            env = [
              {
                name      = "GITHUB_PAT"
                secretRef = "personal-access-token"
              },
              {
                name  = "REPO_URL"
                value = "https://github.com/$REPO_OWNER/$REPO_NAME"
              },
              {
                name  = "REGISTRATION_TOKEN_API_URL"
                value = "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runners/registration-token"
              }
            ]
            image = "string"
            name  = "string"
            resources = {
              cpu    = "2.0"
              memory = "4Gi"
            }
          }
        ]
      }
    }
  })
}
*/

/*
az containerapp job create -n "$JOB_NAME" -g "$RESOURCE_GROUP" --environment "$ENVIRONMENT" \
    --trigger-type Event \

    --image "$CONTAINER_REGISTRY_NAME.azurecr.io/$CONTAINER_IMAGE_NAME" \

    --scale-rule-metadata  \
    --scale-rule-auth "" \

    --registry-server "$CONTAINER_REGISTRY_NAME.azurecr.io"
    */