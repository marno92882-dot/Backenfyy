#!/usr/bin/env python3
"""Reference diagnostic server.

This asset is intentionally limited to harmless health/status endpoints.
It does not decrypt, modify, replay, or forward game authentication traffic.
On Android the app uses the Dart HttpServer because Flutter apps do not ship
with a Python runtime by default.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime, timezone

class Handler(BaseHTTPRequestHandler):
    def _send(self, status, payload):
        raw = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        if self.path in ("/Ping", "/health"):
            self._send(200, {"ok": True, "service": "PC Logo diagnostic server", "timestamp": datetime.now(timezone.utc).isoformat()})
        elif self.path == "/MajorLogin":
            self._send(501, {"ok": False, "error": "MajorLogin interception is not supported by this build."})
        else:
            self._send(404, {"ok": False, "error": "Not found"})

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5030
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
