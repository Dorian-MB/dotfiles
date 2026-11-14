#!/usr/bin/env bash
# Open a notebook in jupynb (headless), save it, and check nothing was lost and
# the result is still valid nbformat. Needs nvim + a python with nbformat.
#   nvim/jupynb.nvim/tests/roundtrip.sh [python]
set -euo pipefail
PY="${1:-python3}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT

"$PY" - "$T" <<'EOF'
import sys, base64, nbformat
t = sys.argv[1]
png = base64.b64encode(bytes.fromhex(
    "89504e470d0a1a0a0000000d4948445200000001000000010806000000"
    "1f15c4890000000d49444154789c6360000002000154a24f5d0000000049454e44ae426082")).decode()
nb = nbformat.v4.new_notebook()
run = nbformat.v4.new_code_cell("print(1)\nprint(2)", execution_count=3)
run.outputs = [
    nbformat.v4.new_output("stream", name="stdout", text="1\n2\n"),
    nbformat.v4.new_output("display_data", data={"application/json": [1, None, 3], "image/png": png}),
]
nb.cells = [nbformat.v4.new_markdown_cell("# title\ntext"), run, nbformat.v4.new_code_cell("never_run()")]
nbformat.write(nb, f"{t}/real.ipynb")
EOF
ln -s "$T/real.ipynb" "$T/link.ipynb"
cp "$T/real.ipynb" "$T/before.ipynb"

nvim --headless -u NONE --cmd "set rtp+=$ROOT" --cmd "runtime plugin/jupynb.lua" \
  -c "lua require('jupynb').setup({})" -c "edit $T/link.ipynb" -c "write" -c "qa!" 2>"$T/nvim.err" \
  || { cat "$T/nvim.err"; exit 1; }
[ -s "$T/nvim.err" ] && { echo "nvim errors:"; cat "$T/nvim.err"; exit 1; }

"$PY" - "$T" <<'EOF'
import sys, nbformat
t = sys.argv[1]
before, after = (nbformat.read(f"{t}/{n}.ipynb", 4) for n in ("before", "real"))
nbformat.validate(after)
strip = lambda nb: [(c.cell_type, c.source, c.get("execution_count"), c.get("outputs")) for c in nb.cells]
assert strip(before) == strip(after), (strip(before), strip(after))
print("roundtrip ok")
EOF
[ -L "$T/link.ipynb" ] || { echo "symlink replaced by a file"; exit 1; }
