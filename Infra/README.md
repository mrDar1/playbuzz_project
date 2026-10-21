# Infra (Terraform)

Creates a local Kubernetes cluster and installs the platform pieces on it:

| What                  | How                                                    |
|-----------------------|--------------------------------------------------------|
| Kubernetes cluster    | [minikube](https://minikube.sigs.k8s.io/) on Docker: **1 control-plane + 2 workers** |
| Ingress controller    | `ingress-nginx` Helm chart (namespace `ingress-nginx`) |
| Argo CD               | `argo-cd` Helm chart (namespace `argocd`)              |

## Files

| File           | Purpose                                                       |
|----------------|---------------------------------------------------------------|
| `versions.tf`  | Terraform + provider versions (`minikube`, `helm`)            |
| `variables.tf` | Tunable inputs (cluster name, node count, CPU/memory, chart versions) |
| `main.tf`      | The cluster, ingress-nginx and Argo CD                        |
| `outputs.tf`   | kubectl context + copy-paste commands to reach the components |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [minikube](https://minikube.sigs.k8s.io/docs/start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Docker running, with **~7 GB RAM** given to Docker Desktop
  (3 nodes x 2 GB by default; lower `memory` or `node_count` if you have less)

Helm does not need to be installed: Terraform's Helm provider embeds it.

## Bring it up

```sh
cd Infra
terraform init
terraform apply        # type "yes"; takes ~5 minutes
```

Terraform runs in this order: minikube cluster -> ingress-nginx -> Argo CD.

## Check it

```sh
kubectl --context dar-test get nodes          # 1 control-plane + 2 workers, all Ready
kubectl --context dar-test get pods -n argocd
kubectl --context dar-test get pods -n ingress-nginx
```

### Open Argo CD

```sh
kubectl --context dar-test -n argocd port-forward svc/argocd-server 8081:80
```

Open <http://localhost:8081>, user `admin`, password:

```sh
kubectl --context dar-test -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

### Reach the ingress controller

minikube on macOS (Docker driver) does not expose node ports to the host, so
use a port-forward:

```sh
kubectl --context dar-test -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
curl -i http://localhost:8080      # 404 from nginx = controller is up, no Ingress yet
```

`terraform output next_steps` prints all of these commands again.

## Tear it down

```sh
terraform destroy      # type "yes"
```

This deletes the Helm releases and then the minikube cluster (and its Docker
containers). Argo CD's three CRDs are intentionally kept by the chart's
resource policy, but they disappear with the cluster.

## Configuration

Override defaults with `-var` or a `terraform.tfvars` file:

```sh
terraform apply -var node_count=3 -var memory=3072
```

| Variable                      | Default   | Notes                                    |
|-------------------------------|-----------|------------------------------------------|
| `cluster_name`                | `dar-test`| minikube profile and kubectl context     |
| `node_count`                  | `3`       | 1 control-plane + (n-1) workers          |
| `cpus`                        | `2`       | per node                                 |
| `memory`                      | `2048`    | MB per node                              |
| `ingress_nginx_chart_version` | `4.11.3`  |                                          |
| `argocd_chart_version`        | `7.7.5`   |                                          |

## Notes / design choices

- **minikube over kind**: matches the project plan and is already installed.
  The Kubernetes version is whatever the provider defaults to (v1.30.0 at the
  time of writing); the provider's `kubernetes_version` setting had no effect
  in testing, so it is not exposed.
- **NodePort ingress**: minikube has no cloud load balancer; a `LoadBalancer`
  Service would stay `<pending>` and make Helm wait forever.
- **Argo CD in HTTP mode** (`server.insecure`): no TLS certificate is needed
  behind a local port-forward/ingress. Not for production.
- **State** is local (`terraform.tfstate`, git-ignored). Don't delete it before
  `terraform destroy`, or run `minikube delete -p dar-test` to clean up by hand.
