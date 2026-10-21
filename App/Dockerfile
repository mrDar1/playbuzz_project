FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PORT=8080

# Numeric UID so Kubernetes runAsNonRoot can verify it
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY --chown=app:app app.py app.html ./

USER 10001:10001

EXPOSE 8080

CMD ["python", "app.py"]
