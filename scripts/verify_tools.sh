#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " VSD DFT Codespace Tool Verification"
echo "============================================================"

echo ""
echo "[1] Fault"
fault --version || true

echo ""
echo "[2] Yosys"
yosys -V

echo ""
echo "[3] Icarus Verilog"
iverilog -V | head -n 1

echo ""
echo "[4] VVP"
vvp -V | head -n 1

echo ""
echo "[5] Pyverilog"
python3 - <<'PY'
import pyverilog
print("Pyverilog installed")
PY

echo ""
echo "[6] Quaigh"
quaigh --help | head -n 5 || true

echo ""
echo "[7] Graphviz"
dot -V

echo ""
echo "============================================================"
echo " All required DFT lab tools are available."
echo "============================================================"
