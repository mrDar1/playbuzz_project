
stage 0.0:
adjust to mac


stage 0.1 - website:
Write a tiny web service in Python. GET / returns an HTML page (not JSON)
that shows, readable in the browser, a message, the app version and the name of the
pod serving it. GET /healthz returns 200.

add readme how to use it

stage 0.2 - Docker it:
create Dockerfile; 
the image runs as a non-root user. 
Build and run it locally to check


Part 1 - Terraform
create Infra:
1. Terraform creates a local Kubernetes cluster (1 control-plane + 2 worker nodes) and
installs Argo CD and an ingress controller.
2. terraform apply brings everything up; terraform destroy removes it.

Part 2 - GitOps deployment
add Argo CD:
1. The app’s Kubernetes manifests live in your repo, and Argo CD syncs them.
2. At least 2 replicas, readiness and liveness probes, and resource requests and limits.
3. The app is exposed through an Ingress and opens in the browser on this laptop.


Part 3 (good to have): CI/CD

Part 4 - Bonus (only if time is left)
In the README: what you’d change to run this on EKS in production

