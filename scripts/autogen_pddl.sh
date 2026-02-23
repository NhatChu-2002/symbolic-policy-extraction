set -euo pipefail

JULIA_FILE="${1:?usage: $0 <tiger.jl> <domain_template.pddl> <out_dir>}"
DOMAIN_TEMPLATE="${2:?usage: $0 <tiger.jl> <domain_template.pddl> <out_dir>}"
OUT_DIR="${3:?usage: $0 <tiger.jl> <domain_template.pddl> <out_dir>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PY_TOOL="$REPO_ROOT/tools/autogen_tiger_pddl.py"
JULIA_PROJECT="$REPO_ROOT/Pomdp"

mkdir -p "$OUT_DIR"
TRACE_FILE="$OUT_DIR/trace.txt"

julia --project="$JULIA_PROJECT" "$JULIA_FILE" > "$TRACE_FILE"

python "$PY_TOOL" \
  --trace "$TRACE_FILE" \
  --domain-template "$DOMAIN_TEMPLATE" \
  --out-dir "$OUT_DIR"

echo "Done!"
echo "Trace:  $TRACE_FILE"
echo "Output: $OUT_DIR"
