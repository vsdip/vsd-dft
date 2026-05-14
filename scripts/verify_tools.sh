#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " VSD DFT Codespace Tool Verification"
echo "============================================================"

echo ""
echo "[1] Swift"
source /home/vscode/.local/share/swiftly/env.sh 2>/dev/null || true
which swift
swift --version

echo ""
echo "[2] OSS CAD Suite"
echo "OSS_CAD_SUITE=${OSS_CAD_SUITE:-/opt/oss-cad-suite}"

echo ""
echo "[3] Yosys"
which yosys
yosys -V

echo ""
echo "[4] ABC"
which abc || true
abc -h | head -n 2 || true

echo ""
echo "[5] Icarus Verilog"
which iverilog
iverilog -V | head -n 1 || true

echo ""
echo "[6] VVP"
which vvp
vvp -V | head -n 1 || true

echo ""
echo "[7] Pyverilog"
python3 - <<'PY'
import pyverilog
print("Pyverilog installed")
PY

echo ""
echo "[8] Quaigh"
which quaigh
quaigh --help | head -n 3

echo ""
echo "[9] Fault"
export LD_LIBRARY_PATH=/home/vscode/.local/share/swiftly/toolchains/6.3.1/usr/lib/swift/linux:${LD_LIBRARY_PATH:-}
which fault
fault --help | head -n 20

echo ""
echo "[10] Graphviz"
which dot
dot -V

echo ""
echo "============================================================"
echo " All required VSD DFT lab tools are available."
echo "============================================================"
