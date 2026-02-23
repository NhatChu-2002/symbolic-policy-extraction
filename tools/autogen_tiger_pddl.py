
from __future__ import annotations
import argparse
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional


@dataclass
class Step:
    k: int = 6
    action: str   # listen|left|right
    obs: str      # left|right
    pleft: Optional[float] = None
    pright: Optional[float] = None


def parse_trace(text: str) -> List[Step]:
    
    steps: List[Step] = []
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("TRACE,"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) < 4:
            continue
        
        k = int(parts[1])
        action = parts[2].lower()
        obs = parts[3].lower()
        pleft = float(parts[4]) if len(parts) > 4 else None
        pright = float(parts[5]) if len(parts) > 5 else None
        steps.append(Step(k=k, action=action, obs=obs, pleft=pleft, pright=pright))

    if not steps:
        raise ValueError("No TRACE lines found.")
    return steps


def write_problem(
    out_problem: Path,
    steps: List[Step],
    problem_name: str = "tiger-policy-run",
    use_uppercase_nodes: bool = True,
) -> None:
    
    if use_uppercase_nodes:
        nodes = ["B0", "BL1", "BL2", "BL3", "BR1", "BR2", "BR3"]
    else:
        nodes = ["b0", "bl1", "bl2", "bl3", "br1", "br2", "br3"]

    T = len(steps)
    tapes = [f"t{i}" for i in range(T)]

    # next chain
    next_facts = []
    for i in range(T - 1):
        next_facts.append(f"(next t{i} t{i+1})")

    # obs facts
    obs_facts = []
    for i, st in enumerate(steps):
        if st.obs == "left":
            obs_facts.append(f"(obs-left t{i})")
        elif st.obs == "right":
            obs_facts.append(f"(obs-right t{i})")
        else:
            raise ValueError(f"Unknown obs '{st.obs}' at step {i}")

    consumed_facts = []
    for i, st in enumerate(steps):
        if st.action != "listen":
            consumed_facts.append(f"(consumed t{i})")

    # objects
    node_objs = " ".join(nodes) + " - node"
    tape_objs = " ".join(tapes) + " - tape"

    init_lines = []
    init_lines.append(f"(at {nodes[0]})")  # B0 or b0
    init_lines.append("(k0)")
    init_lines.append("(b-unk)")
    init_lines.append("(tape-at t0)")
    init_lines += next_facts
    init_lines += obs_facts
    init_lines += consumed_facts

    problem = f"""(define (problem {problem_name})
  (:domain tiger-policy-fsc)

  (:objects
    {node_objs}
    {tape_objs}
  )

  (:init
    ;; controller start
    {init_lines[0]}

    ;; counter start
    {init_lines[1]}

    ;; belief start
    {init_lines[2]}

    ;; tape head
    {init_lines[3]}

    ;; tape successor chain
    {" ".join(next_facts)}

    ;; observations 
    {" ".join(obs_facts)}

    ;; mark open steps as already consumed 
    {" ".join(consumed_facts)}
  )

  (:goal (done))
)
"""
    out_problem.write_text(problem, encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("trace", help="Trace input file, or '-' for stdin")
    ap.add_argument("--domain-template", required=True, help="Path to your fixed domain template PDDL")
    ap.add_argument("--out-domain", required=True, help="Output domain file path")
    ap.add_argument("--out-problem", required=True, help="Output problem file path")
    ap.add_argument("--problem-name", default="tiger-policy-run")
    ap.add_argument("--lowercase-nodes", action="store_true", help="Use b0/bl1/... instead of B0/BL1/...")
    args = ap.parse_args()

    
    if args.trace == "-":
        text = sys.stdin.read()
    else:
        text = Path(args.trace).read_text(encoding="utf-8")

    steps = parse_trace(text)

    dom_src = Path(args.domain_template)
    dom_dst = Path(args.out_domain)
    dom_dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(dom_src, dom_dst)

    # Write problem
    prob_dst = Path(args.out_problem)
    prob_dst.parent.mkdir(parents=True, exist_ok=True)
    write_problem(
        prob_dst,
        steps,
        problem_name=args.problem_name,
        use_uppercase_nodes=(not args.lowercase_nodes),
    )

    print(f"Wrote domain : {dom_dst}")
    print(f"Wrote problem: {prob_dst}")
    print(f"Tape length  : {len(steps)} (one cell per TRACE line)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
