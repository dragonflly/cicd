#############################################################################
# Install Metrics Server using HELM, used by HPA and VPA
resource "helm_release" "metrics_server_release" {
  name       = "${local.name}-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace = "kube-system"   
}


#############################################################################
# Outputs
output "metrics_server_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.metrics_server_release.metadata
}


#############################################################################
