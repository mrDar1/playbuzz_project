import threading
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer

import app


class AppTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), app.Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def get(self, path):
        try:
            with urllib.request.urlopen(self.base + path) as r:
                return r.status, r.read().decode()
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode()

    def test_healthz(self):
        self.assertEqual(self.get("/healthz"), (200, "ok\n"))

    def test_index_shows_message_version_and_pod(self):
        status, body = self.get("/")
        self.assertEqual(status, 200)
        self.assertIn(app.MESSAGE, body)
        self.assertIn(app.VERSION, body)
        self.assertIn(app.POD, body)

    def test_unknown_path_is_404(self):
        self.assertEqual(self.get("/nope")[0], 404)


if __name__ == "__main__":
    unittest.main()
