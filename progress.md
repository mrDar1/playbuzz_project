# Progress log

## 2026-10-21 - Project setup and plan
- What was done: repo initialised; `documentation/plan.md` captures the task (tiny demo website on K8s with Terraform and ArgoCD) and stage 0.0 choices (macOS, VS Code, minikube, Claude as AI). `documentation/ai-prompts.md` records the prompts used.
- Files: `README.md`, `documentation/plan.md`, `documentation/ai-prompts.md`

## 2026-10-21 - Stage 0.1 and 0.2: web service and Docker image
- What was done: Python standard-library service in `App/`. `GET /` renders an HTML page (message, app version, pod name; values HTML-escaped). `GET /healthz` returns 200 `ok`. Configured via `MESSAGE`, `APP_VERSION`, `POD_NAME`, `HOSTNAME` and `PORT`. Dockerfile based on `python:3.13-slim`, running as non-root numeric UID 10001, port 8080.
- Files: `App/app.py`, `App/app.html`, `App/Dockerfile`, `App/.dockerignore`, `App/README.md`
- Notes: the plan says to build and run the image locally to check it. No record of that check was found, so it is unverified.

## 2026-10-21 - Part 1: Terraform infra
- What was done: Terraform creates a minikube (Docker driver) cluster with 3 nodes (1 control-plane + 2 workers) and installs ingress-nginx (NodePort) and Argo CD (`server.insecure=true`) via Helm. Outputs give the kubectl context and port-forward commands. Chart versions: ingress-nginx 4.11.3, argo-cd 7.7.5.
- Files: `Infra/main.tf`, `Infra/variables.tf`, `Infra/outputs.tf`, `Infra/versions.tf`, `Infra/.terraform.lock.hcl`, `Infra/.gitignore`, `Infra/README.md`
- Notes: `terraform apply` and `destroy` have not been confirmed to work from anything in the repo.

## 2026-10-21 - Docs updates (uncommitted)
- What was done: edits to `README.md`, `Infra/README.md` (+14 lines) and `documentation/ai-prompts.md` are in the working tree but not committed. Added `CLAUDE.md` with the progress-logging instructions, and this `progress.md`.
- Files: `README.md`, `Infra/README.md`, `documentation/ai-prompts.md`, `CLAUDE.md`, `progress.md`

## Not started
- Part 2: GitOps deployment. Argo CD Application and Kubernetes manifests with at least 2 replicas, readiness and liveness probes, resource requests and limits, and an Ingress reachable from the laptop. The plan says to consult before doing anything here.
- Part 3 (optional): CI/CD.
- Part 4 (bonus): README section on what to change to run on EKS in production.

## 2026-10-21 - Part 3: GitHub Actions CI
- What was done: added `.github/workflows/ci.yml`. On push/PR to main: ruff lint of `App/`, Docker build, smoke test (`/healthz` and `/`). On push to main only: log in to Docker Hub and push `yuval222/playbuzz_project` tagged `latest` and the git SHA.
- Files: `.github/workflows/ci.yml`, `progress.md`
- Notes: the repo has no unit tests, so the smoke test stands in for them. Requires repo secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`. Workflow has not been run. `Deploy/app/deployment.yaml` still pins `1.0.0`, which CI does not push; follow-up: switch it to a SHA tag or push a version tag.

## 2026-10-21 - CI follow-ups: tests and image tag fix
- What was done: added `App/test_app.py` (3 unittest tests: `/healthz`, `/`, 404) and a CI "Unit tests" step. Added an `update-manifest` job that, after a push to main, rewrites the image tag in `Deploy/app/deployment.yaml` to the commit SHA and commits it with `[skip ci]`, so Argo CD deploys what CI pushed. Changed the placeholder tag `1.0.0` to `latest` in the manifest.
- Files: `App/test_app.py`, `App/.dockerignore`, `.github/workflows/ci.yml`, `Deploy/app/deployment.yaml`
- Notes: tests pass locally. Workflow not run yet. The bot commit to main needs "Workflow permissions: read and write" if the repo setting is read-only, and fails if branch protection blocks pushes.

## 2026-10-21 - Full local run check
- What was done: ran unit tests (3/3 pass), built the Docker image and ran it (`/healthz` 200, `/` renders, unknown path 404, container runs as uid 10001), rendered `Deploy/app` with kustomize (ok), `terraform validate` (valid).
- Files: `progress.md`
- Notes: not verified: Kubernetes/Argo CD deploy (kube context `dar-test` exists but API server at 127.0.0.1:50869 refuses connections, cluster is stopped) and the GitHub Actions workflow (never run).
