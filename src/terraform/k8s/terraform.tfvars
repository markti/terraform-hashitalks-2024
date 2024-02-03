k8s_namespace            = "app"
k8s_service_account_name = "workload"

health_check_image = {
  name = "health-check"
  tag  = "v2024.01.1"
}
user_svc_image = {
  name = "user-svc"
  tag  = "v2024.01.1"
}