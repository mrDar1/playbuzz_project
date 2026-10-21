output "kube_context" {
  description = "kubectl context for the new cluster."
  value       = minikube_cluster.this.cluster_name
}

output "next_steps" {
  description = "Commands to reach the installed components."
  value       = <<-EOT
    kubectl --context ${minikube_cluster.this.cluster_name} get nodes

    # Argo CD UI -> http://localhost:8081  (user: admin)
    kubectl --context ${minikube_cluster.this.cluster_name} -n argocd port-forward svc/argocd-server 8081:80
    kubectl --context ${minikube_cluster.this.cluster_name} -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

    # Ingress controller -> http://localhost:8080
    kubectl --context ${minikube_cluster.this.cluster_name} -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
  EOT
}
