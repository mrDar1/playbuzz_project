variable "cluster_name" {
  description = "Minikube profile / kubectl context name."
  type        = string
  default     = "dar-test"
}

variable "node_count" {
  description = "Total nodes: 1 control-plane + (node_count - 1) workers."
  type        = number
  default     = 3
}

variable "cpus" {
  description = "CPUs per node."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory per node in MB. 3 nodes x 2048 MB needs ~6 GB free in Docker Desktop."
  type        = number
  default     = 2048
}

variable "ingress_nginx_chart_version" {
  description = "ingress-nginx Helm chart version."
  type        = string
  default     = "4.11.3"
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version."
  type        = string
  default     = "7.7.5"
}
