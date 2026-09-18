#!/usr/bin/env python3
"""Bridge between Neovim (jupynb.nvim) and a Jupyter kernel.

Protocol: one JSON object per line, both ways.

Neovim -> bridge
    {"op": "kernels"}
    {"op": "start", "kernel": "python3", "cwd": "...", "python": "/path/to/python"}
    {"op": "execute", "id": "<cell id>", "code": "..."}
    {"op": "interrupt"} | {"op": "restart"} | {"op": "shutdown"}
    {"op": "input", "text": "..."}
    {"op": "complete", "id": "...", "code": "...", "pos": 12}

bridge -> Neovim
    {"ev": "kernels", "specs": [...]}
    {"ev": "kernel_status", "state": "starting|idle|busy|dead|restarting"}
    {"ev": "cell_status", "id": "...", "state": "running", "execution_count": 3}
    {"ev": "output", "id": "...", "output": {<nbformat output>}}
    {"ev": "clear", "id": "...", "wait": false}
    {"ev": "exec_reply", "id": "...", "status": "ok", "execution_count": 3, "elapsed": 0.4}
    {"ev": "input_request", "id": "...", "prompt": "...", "password": false}
    {"ev": "error", "msg": "..."}
"""

from __future__ import annotations

import base64
import json
import os
import queue
import shutil
import sys
import tempfile
import threading
import time
import uuid

IMAGE_MIMES = {
    "image/png": "png",
    "image/jpeg": "jpg",
    "image/gif": "gif",
    "image/webp": "webp",
}

_out_lock = threading.Lock()


def send(**obj):
    try:
        line = json.dumps(obj, ensure_ascii=False, default=str)
    except Exception as exc:  # pragma: no cover - defensive
        line = json.dumps({"ev": "error", "msg": "encode failed: %s" % exc})
    with _out_lock:
        sys.stdout.write(line + "\n")
        sys.stdout.flush()


class Bridge:
    def __init__(self):
        self.km = None
        self.kc = None
        self.alive = False
        self.cells = {}  # jupyter msg_id -> notebook cell id
        self.started_at = {}  # msg_id -> time
        self.tmpdir = tempfile.mkdtemp(prefix="jupynb-")
        self.kernel_name = None
        self.display_name = None
        self.language = "python"
        self.threads = []

    # ------------------------------------------------------------------ utils
    def log(self, msg, level="error"):
        send(ev="error", msg=str(msg), level=level)

    # ------------------------------------------------------- kernel lifecycle
    def op_kernels(self, req):
        specs = []
        try:
            from jupyter_client.kernelspec import KernelSpecManager

            for name, info in KernelSpecManager().get_all_specs().items():
                spec = info.get("spec", {})
                specs.append(
                    {
                        "name": name,
                        "display_name": spec.get("display_name", name),
                        "language": spec.get("language", ""),
                        "argv": spec.get("argv", []),
                    }
                )
        except Exception as exc:
            self.log("cannot list kernels: %s" % exc)
        specs.sort(key=lambda s: (s["language"] != "python", s["display_name"].lower()))
        send(ev="kernels", specs=specs)

    def op_start(self, req):
        if self.kc is not None:
            self.op_shutdown({})
        name = req.get("kernel") or "python3"
        python = req.get("python")
        cwd = req.get("cwd") or os.getcwd()
        send(ev="kernel_status", state="starting", kernel=name)
        try:
            from jupyter_client.manager import KernelManager

            km = KernelManager(kernel_name=name)
            spec = km.kernel_spec  # may raise NoSuchKernel
            if python:
                if not os.path.exists(python):
                    raise RuntimeError("python not found: %s" % python)
                spec.argv = [
                    python,
                    "-m",
                    "ipykernel_launcher",
                    "-f",
                    "{connection_file}",
                ]
                spec.display_name = "%s (%s)" % (
                    spec.display_name,
                    os.path.basename(os.path.dirname(os.path.dirname(python))),
                )
            env = dict(os.environ)
            env.setdefault("PYDEVD_DISABLE_FILE_VALIDATION", "1")
            km.start_kernel(cwd=cwd, env=env)
            kc = km.client()
            kc.start_channels()
            kc.wait_for_ready(timeout=req.get("timeout", 60))
        except Exception as exc:
            hint = ""
            if python and "ipykernel" in str(exc).lower():
                hint = " (install ipykernel in that environment)"
            self.log("kernel start failed: %s%s" % (exc, hint))
            send(ev="kernel_status", state="dead", kernel=name)
            return

        self.km, self.kc = km, kc
        self.kernel_name = name
        self.display_name = spec.display_name
        self.language = spec.language or "python"
        self.alive = True
        self._spawn_listeners()
        send(
            ev="kernel_status",
            state="idle",
            kernel=name,
            display=self.display_name,
            language=self.language,
        )

    def _spawn_listeners(self):
        self.threads = []
        for target in (self._iopub_loop, self._shell_loop, self._stdin_loop):
            th = threading.Thread(target=target, daemon=True)
            th.start()
            self.threads.append(th)

    def op_interrupt(self, req):
        if self.km:
            try:
                self.km.interrupt_kernel()
            except Exception as exc:
                self.log("interrupt failed: %s" % exc)

    def op_restart(self, req):
        if not self.km:
            return
        send(ev="kernel_status", state="restarting")
        try:
            self.km.restart_kernel(now=req.get("now", False))
            self.kc.wait_for_ready(timeout=60)
            self.cells.clear()
            self.started_at.clear()
            send(ev="kernel_status", state="idle", kernel=self.kernel_name, display=self.display_name)
        except Exception as exc:
            self.log("restart failed: %s" % exc)
            send(ev="kernel_status", state="dead")

    def op_shutdown(self, req):
        self.alive = False
        try:
            if self.kc:
                self.kc.stop_channels()
            if self.km:
                self.km.shutdown_kernel(now=True)
        except Exception:
            pass
        self.km = self.kc = None
        send(ev="kernel_status", state="dead")

    # ------------------------------------------------------------- execution
    def op_execute(self, req):
        if not self.kc:
            self.log("no kernel running")
            return
        cell = req.get("id")
        code = req.get("code", "")
        try:
            msg_id = self.kc.execute(code, store_history=True, allow_stdin=True)
        except Exception as exc:
            self.log("execute failed: %s" % exc)
            return
        self.cells[msg_id] = cell
        self.started_at[msg_id] = time.time()
        send(ev="cell_status", id=cell, state="queued")

    def op_input(self, req):
        if self.kc:
            try:
                self.kc.input(req.get("text", ""))
            except Exception as exc:
                self.log("input failed: %s" % exc)

    def op_complete(self, req):
        if not self.kc:
            return
        try:
            msg_id = self.kc.complete(req.get("code", ""), req.get("pos", 0))
            self.cells[msg_id] = req.get("id")
        except Exception as exc:
            self.log("complete failed: %s" % exc)

    # ------------------------------------------------------------- listeners
    def _iopub_loop(self):
        while self.alive and self.kc:
            try:
                msg = self.kc.get_iopub_msg(timeout=0.25)
            except queue.Empty:
                continue
            except Exception:
                if self.alive:
                    time.sleep(0.1)
                continue
            try:
                self._handle_iopub(msg)
            except Exception as exc:
                self.log("iopub: %s" % exc)

    def _shell_loop(self):
        while self.alive and self.kc:
            try:
                msg = self.kc.get_shell_msg(timeout=0.25)
            except queue.Empty:
                continue
            except Exception:
                if self.alive:
                    time.sleep(0.1)
                continue
            try:
                self._handle_shell(msg)
            except Exception as exc:
                self.log("shell: %s" % exc)

    def _stdin_loop(self):
        while self.alive and self.kc:
            try:
                msg = self.kc.get_stdin_msg(timeout=0.25)
            except queue.Empty:
                continue
            except Exception:
                if self.alive:
                    time.sleep(0.1)
                continue
            if msg.get("msg_type") == "input_request":
                content = msg.get("content", {})
                send(
                    ev="input_request",
                    id=self.cells.get(msg["parent_header"].get("msg_id")),
                    prompt=content.get("prompt", ""),
                    password=bool(content.get("password", False)),
                )

    # --------------------------------------------------------- message logic
    def _handle_iopub(self, msg):
        parent = msg.get("parent_header", {}).get("msg_id")
        cell = self.cells.get(parent)
        mtype = msg.get("msg_type")
        content = msg.get("content", {})

        if mtype == "status":
            state = content.get("execution_state", "idle")
            send(ev="kernel_status", state=state)
            return

        if cell is None:
            # Output produced outside of a tracked execution (e.g. background
            # thread). Drop it rather than attaching it to the wrong cell.
            return

        if mtype == "execute_input":
            send(
                ev="cell_status",
                id=cell,
                state="running",
                execution_count=content.get("execution_count"),
            )
        elif mtype == "stream":
            send(
                ev="output",
                id=cell,
                output={
                    "output_type": "stream",
                    "name": content.get("name", "stdout"),
                    "text": content.get("text", ""),
                },
            )
        elif mtype in ("execute_result", "display_data", "update_display_data"):
            out = {
                "output_type": "execute_result" if mtype == "execute_result" else "display_data",
                "data": self._store_data(content.get("data", {})),
                "metadata": content.get("metadata", {}) or {},
            }
            if mtype == "execute_result":
                out["execution_count"] = content.get("execution_count")
            send(ev="output", id=cell, output=out)
        elif mtype == "error":
            send(
                ev="output",
                id=cell,
                output={
                    "output_type": "error",
                    "ename": content.get("ename", "Error"),
                    "evalue": content.get("evalue", ""),
                    "traceback": content.get("traceback", []),
                },
            )
        elif mtype == "clear_output":
            send(ev="clear", id=cell, wait=bool(content.get("wait", False)))

    def _handle_shell(self, msg):
        mtype = msg.get("msg_type")
        parent = msg.get("parent_header", {}).get("msg_id")
        cell = self.cells.get(parent)
        content = msg.get("content", {})
        if mtype == "execute_reply":
            elapsed = None
            if parent in self.started_at:
                elapsed = round(time.time() - self.started_at.pop(parent), 4)
            send(
                ev="exec_reply",
                id=cell,
                status=content.get("status", "ok"),
                execution_count=content.get("execution_count"),
                elapsed=elapsed,
            )
            self.cells.pop(parent, None)
        elif mtype == "complete_reply":
            send(
                ev="complete_reply",
                id=cell,
                matches=content.get("matches", []),
                cursor_start=content.get("cursor_start"),
                cursor_end=content.get("cursor_end"),
            )
            self.cells.pop(parent, None)

    def _store_data(self, data):
        """Write image payloads to disk; Neovim only receives file paths."""
        out = {}
        for mime, value in (data or {}).items():
            ext = IMAGE_MIMES.get(mime)
            if ext and isinstance(value, str):
                try:
                    raw = base64.b64decode(value)
                    path = os.path.join(self.tmpdir, "%s.%s" % (uuid.uuid4().hex, ext))
                    with open(path, "wb") as fh:
                        fh.write(raw)
                    entry = {"_jupynb_path": path, "bytes": len(raw)}
                    dims = _image_size(path)
                    if dims:
                        entry["width"], entry["height"] = dims
                    out[mime] = entry
                except Exception as exc:
                    out["text/plain"] = "<%s: %s>" % (mime, exc)
            else:
                out[mime] = value
        return out

    # -------------------------------------------------------------- main loop
    def run(self):
        ops = {
            "kernels": self.op_kernels,
            "start": self.op_start,
            "execute": self.op_execute,
            "interrupt": self.op_interrupt,
            "restart": self.op_restart,
            "shutdown": self.op_shutdown,
            "input": self.op_input,
            "complete": self.op_complete,
        }
        send(ev="ready", pid=os.getpid(), python=sys.executable)
        for line in sys.stdin:
            line = line.strip()
            if not line:
                continue
            try:
                req = json.loads(line)
            except Exception as exc:
                self.log("bad request: %s" % exc)
                continue
            fn = ops.get(req.get("op"))
            if not fn:
                self.log("unknown op: %s" % req.get("op"))
                continue
            try:
                fn(req)
            except Exception as exc:
                import traceback as tb

                self.log("%s: %s\n%s" % (req.get("op"), exc, tb.format_exc()))
        self.op_shutdown({})
        shutil.rmtree(self.tmpdir, ignore_errors=True)


def _image_size(path):
    try:
        from PIL import Image

        with Image.open(path) as img:
            return img.size
    except Exception:
        return None


if __name__ == "__main__":
    try:
        Bridge().run()
    except KeyboardInterrupt:
        pass
