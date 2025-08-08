resource "kubernetes_service_account" "llm_inference_api_alb_service_account" {
  metadata {
    name      = "aws-alb-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.llm_inference_api_alb_controller_role.arn
    }
  }

  automount_service_account_token = true

  depends_on = [
    time_sleep.delay_for_access_entry
  ]
}