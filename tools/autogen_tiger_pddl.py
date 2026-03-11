from __future__ import annotations

import argparse
import csv
import re
import shutil
from pathlib import Path
from typing import List, Optional, Tuple


def read_listen_sequence(csv_path: Path, trace_id: Optional[int] = None) -> List[str]:
    
    seq: List[str] = []
    with csv_path.open("r", newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            if not row or len(row) < 4:
                continue
            if row[0].strip() != "TRACE":
                continue

            try:
                tid = int(row[1].strip())
            except ValueError:
                continue

            action = row[2].strip().lower()
            sym = row[3].strip().lower()

            if trace_id is not None and tid != trace_id:
                continue

            if action == "listen":
                if sym not in ("left", "right"):
                    raise ValueError(f"Unexpected listen symbol '{sym}' in row: {row}")
                seq.append(sym)

    if not seq:
        raise ValueError(f"No listen rows found in {csv_path} (trace_id={trace_id}).")
    return seq


def build_tape(seq: List[str]) -> Tuple[List[str], List[Tuple[str, str]], List[str]]:
    n = len(seq)
    tape_objs = [f"t{i}" for i in range(n)]
    next_links = [(f"t{i}", f"t{i+1}") for i in range(n - 1)]
    obs_facts = [
        (f"(obs-left t{i})" if sym == "left" else f"(obs-right t{i})")
        for i, sym in enumerate(seq)
    ]
    return tape_objs, next_links, obs_facts


def next_index(autogen_dir: Path) -> int:
    autogen_dir.mkdir(parents=True, exist_ok=True)
    pattern = re.compile(r"policy_domain_(\d+)\.pddl$")
    nums = []
    for p in autogen_dir.glob("policy_domain_*.pddl"):
        m = pattern.search(p.name)
        if m:
            nums.append(int(m.group(1)))
    return (max(nums) + 1) if nums else 1


def write_problem(
    out_path: Path,
    tape_objs: List[str],
    next_links: List[Tuple[str, str]],
    obs_facts: List[str],
    use_tags: bool,
    goal_confirm: bool,
) -> None:

    node_line = "b0 bl1 bl2 bl3 br1 br2 br3 - node"
    tape_line = " ".join(tape_objs) + " - tape"

    obj_lines = [node_line, tape_line]
    init_lines = [
        "(at b0)",
        "(k0)",
        "(tape-at t0)",
    ]

    if use_tags:
        obj_lines.append("tagL tagR - tag")
        init_lines.append("(tiger-left tagL)")
        init_lines.append("(tiger-right tagR)")

    init_lines += [f"(next {a} {b})" for a, b in next_links]
    init_lines += obs_facts

    goal = "(and (done) (tiger-confirmed))" if goal_confirm else "(done)"

    text = f"""(define (problem tiger-policy-run)
  (:domain tiger-policy-fsc)

  (:objects
    {'\n    '.join(obj_lines)}
  )

  (:init
    {'\n    '.join(init_lines)}
  )

  (:goal {goal})
)
"""
    out_path.write_text(text)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--template", required=True, type=Path,
                    help="Path to tiger domain template PDDL (actions are stored here).")
    ap.add_argument("--csv", required=True, type=Path,
                    help="Path to Julia CSV trace file.")
    ap.add_argument("--autogen-root", required=True, type=Path,
                    help="Root autogen folder, e.g. policy_exprm_autogen")
    ap.add_argument("--problem-name", default="tiger",
                    help="Subfolder under autogen-root (default: tiger)")
    ap.add_argument("--trace-id", type=int, default=None,
                    help="Compile only one TRACE id (optional).")

    ap.add_argument("--tags", action="store_true",
                    help="If set, include tagL/tagR objects and (tiger-left tagL)/(tiger-right tagR) in init.")

    ap.add_argument("--no-confirm", action="store_true",
                    help="If set, goal is (done) instead of (and (done) (tiger-confirmed)).")
    ap.add_argument("--copy-csv", action="store_true",
                    help="If set, copy the input CSV into the autogen/tiger folder as trace.csv")
    args = ap.parse_args()

    template_path: Path = args.template
    csv_path: Path = args.csv

    if not template_path.exists():
        raise FileNotFoundError(template_path)
    if not csv_path.exists():
        raise FileNotFoundError(csv_path)

    out_dir = args.autogen_root / args.problem_name
    out_dir.mkdir(parents=True, exist_ok=True)

    idx = next_index(out_dir)

    domain_out = out_dir / f"policy_domain_{idx}.pddl"
    shutil.copyfile(template_path, domain_out)

    seq = read_listen_sequence(csv_path, trace_id=args.trace_id)
    tape_objs, next_links, obs_facts = build_tape(seq)

    problem_out = out_dir / f"policy_problem_{idx}.pddl"
    write_problem(
        out_path=problem_out,
        tape_objs=tape_objs,
        next_links=next_links,
        obs_facts=obs_facts,
        use_tags=args.tags,
        goal_confirm=(not args.no_confirm),
    )

    if args.copy_csv:
        shutil.copyfile(csv_path, out_dir / "trace.csv")

    print(f"[OK] wrote: {domain_out}")
    print(f"[OK] wrote: {problem_out}")
    print(f"[OK] tape length (listen rows): {len(seq)}")
    if args.trace_id is not None:
        print(f"[OK] used TRACE id: {args.trace_id}")
    if args.tags:
        print("[OK] included tagL/tagR and tagged tiger facts in init")
    if args.copy_csv:
        print(f"[OK] copied csv -> {out_dir / 'trace.csv'}")


if __name__ == "__main__":
    main()