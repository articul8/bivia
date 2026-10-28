"""Minimal Bivia client for the cookbook recipes. Python 3.9+, standard library only.

Reads A8_API_KEY (and optionally BIVIA_URL) from the environment or from the cookbook's .env.
"""
import base64
import json
import mimetypes
import os
import pathlib
import time
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent

_env = ROOT / ".env"
if _env.exists():
    for line in _env.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip().strip("'\""))

BASE = os.environ.get("BIVIA_URL", "https://api.articul8.ai/bivia").rstrip("/")
KEY = os.environ.get("A8_API_KEY", "")


def bivia(endpoint, body, timeout=180):
    """POST a JSON body to a Bivia endpoint ("/boolean", "/span", "/ground", ...).

    Returns {"http": status, "ms": elapsed, "response": parsed JSON}.
    """
    if not KEY:
        raise SystemExit("A8_API_KEY is not set. Copy .env.example to .env at the cookbook root and fill it in.")
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {KEY}"}
    req = urllib.request.Request(BASE + endpoint, data=json.dumps(body).encode("utf-8"), headers=headers, method="POST")
    t0 = time.monotonic()
    try:
        with urllib.request.urlopen(req, timeout=timeout) as res:
            status, text = res.status, res.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        status, text = e.code, e.read().decode("utf-8", "replace")
    ms = round((time.monotonic() - t0) * 1000)
    try:
        response = json.loads(text)
    except ValueError:
        response = {"error": text[:400]}
    return {"http": status, "ms": ms, "response": response}


def file(path, **extra):
    """A file as the {b64, mime} object Bivia expects in images[], documents[] or video."""
    path = pathlib.Path(path)
    mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    return {"b64": base64.b64encode(path.read_bytes()).decode("ascii"), "mime": mime, **extra}
