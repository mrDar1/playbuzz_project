# Tiny web service

A minimal Python service (standard library only, Python 3.8+).

| Endpoint       | Response                                                  |
|----------------|-----------------------------------------------------------|
| `GET /`        | HTML page showing a message, the app version and pod name |
| `GET /healthz` | `200 OK` (body: `ok`)                                     |

## Run

```sh
cd App
python3 app.py
```

Then open <http://localhost:8080/>, or check health:

```sh
curl -i http://localhost:8080/healthz
```

## Configuration (environment variables)

| Variable      | Default                           | Purpose                                                        |
|---------------|-----------------------------------|----------------------------------------------------------------|
| `MESSAGE`     | `Hello from the tiny web service!`| Message shown on the page                                      |
| `APP_VERSION` | `1.0.0`                           | Version shown on the page                                      |
| `POD_NAME`    | _unset_                           | Pod name override                                              |
| `HOSTNAME`    | set by the OS / Kubernetes        | Used as the pod name when `POD_NAME` is unset (K8s sets it to the pod name) |
| `PORT`        | `8080`                            | Port to listen on                                              |

Example:

```sh
MESSAGE="Hi there" APP_VERSION=2.1.0 PORT=9000 python3 app.py
```

## Kubernetes notes

- The pod name is picked up automatically from `HOSTNAME`.
- Use `/healthz` for liveness/readiness probes:

```yaml
livenessProbe:
  httpGet: { path: /healthz, port: 8080 }
readinessProbe:
  httpGet: { path: /healthz, port: 8080 }
```

- Keep `app.html` next to `app.py` (e.g. copy both into the container image).
