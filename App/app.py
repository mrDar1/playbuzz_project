import os
import socket
from html import escape
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from string import Template

TEMPLATE = Template((Path(__file__).parent / "app.html").read_text())

MESSAGE = os.environ.get("MESSAGE", "Hello from the tiny web service!")
VERSION = os.environ.get("APP_VERSION", "1.0.0")
# Kubernetes sets HOSTNAME to the pod name; POD_NAME can override it.
POD = os.environ.get("POD_NAME") or os.environ.get("HOSTNAME") or socket.gethostname()
PORT = int(os.environ.get("PORT", "8080"))


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body, content_type="text/plain; charset=utf-8"):
        data = body.encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/":
            page = TEMPLATE.substitute(
                message=escape(MESSAGE), version=escape(VERSION), pod=escape(POD)
            )
            self._send(200, page, "text/html; charset=utf-8")
        elif path == "/healthz":
            self._send(200, "ok\n")
        else:
            self._send(404, "not found\n")


if __name__ == "__main__":
    print(f"Listening on :{PORT} (pod={POD}, version={VERSION})")
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()
