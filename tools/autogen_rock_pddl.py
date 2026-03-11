from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path
from typing import Dict, List, Tuple


def next_index(autogen_dir: Path) -> int:
    autogen_dir.mkdir(parents=True, exist_ok=True)
    pattern = re.compile(r"policy_domain_(\d+)\.pddl$")
    nums = []
    for p in autogen_dir.glob("policy_domain_*.pddl"):
        m = pattern.search(p.name)
        if m:
            nums.append(int(m.group(1)))
    return (max(nums) + 1) if nums else 1


def parse_trace_rows(csv_path: Path) -> List[Dict]:
    """
    Expected rows:
      TRACE,t,x,y,a,o,p_good_1,p_good_2,...,p_good_k
    """
    rows: List[Dict] = []

    with csv_path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        for row in reader:
            if not row:
                continue
            if row[0].strip() != "TRACE":
                continue
            if len(row) < 7:
                continue

            try:
                t = int(row[1].strip())
                x = int(row[2].strip())
                y = int(row[3].strip())
                a = int(row[4].strip())
                o = int(row[5].strip())
                probs = [float(v.strip()) for v in row[6:]]
            except ValueError as e:
                raise ValueError(f"Bad CSV row: {row}") from e

            if not probs:
                raise ValueError(f"No probability columns found in row: {row}")

            rows.append({
                "t": t,
                "x": x,
                "y": y,
                "a": a,
                "o": o,
                "probs": probs,
            })

    if not rows:
        raise ValueError(f"No valid TRACE rows found in {csv_path}")

    rows.sort(key=lambda r: r["t"])

    n_rocks = len(rows[0]["probs"])
    for r in rows:
        if len(r["probs"]) != n_rocks:
            raise ValueError(
                f"Inconsistent number of rock probabilities. "
                f"Expected {n_rocks}, got {len(r['probs'])} at t={r['t']}"
            )

    times = [r["t"] for r in rows]
    expected = list(range(times[0], times[0] + len(times)))
    if times != expected:
        raise ValueError(f"TRACE times must be contiguous. Got {times}, expected {expected}")

    return rows


def cell_name(x: int, y: int) -> str:
    return f"c{x}_{y}"


def bucket_name(p: float, good_threshold: float, bad_threshold: float) -> str:
    if p >= good_threshold:
        return "good"
    if p <= bad_threshold:
        return "bad"
    return "unk"


def build_components(rows: List[Dict], good_threshold: float, bad_threshold: float) -> Dict:
    n = len(rows)
    n_rocks = len(rows[0]["probs"])

    cells: List[str] = []
    seen = set()
    for r in rows:
        c = cell_name(r["x"], r["y"])
        if c not in seen:
            seen.add(c)
            cells.append(c)

    tapes = [f"t{i}" for i in range(n + 1)]
    next_links = [(f"t{i}", f"t{i+1}") for i in range(n)]
    last_t = f"t{n}"

    last_row = rows[-1]

    pos_facts = [f"(pos {cell_name(r['x'], r['y'])} t{r['t']})" for r in rows]
    pos_facts.append(f"(pos {cell_name(last_row['x'], last_row['y'])} t{n})")

    do_facts = [f"(do a{r['a']} t{r['t']})" for r in rows]
    do_facts.append(f"(do a{last_row['a']} t{n})")

    obs_facts = [f"(obs-at o{r['o']} t{r['t']})" for r in rows]
    obs_facts.append(f"(obs-at o{last_row['o']} t{n})")

    belief_facts: List[str] = []
    for r in rows:
        tname = f"t{r['t']}"
        for i, p in enumerate(r["probs"], start=1):
            b = bucket_name(p, good_threshold, bad_threshold)
            if b == "good":
                belief_facts.append(f"(bgood r{i} {tname})")
            elif b == "bad":
                belief_facts.append(f"(bbad r{i} {tname})")
            else:
                belief_facts.append(f"(bunk r{i} {tname})")

    # duplicate last belief bucket on extra final token
    tname = f"t{n}"
    for i, p in enumerate(last_row["probs"], start=1):
        b = bucket_name(p, good_threshold, bad_threshold)
        if b == "good":
            belief_facts.append(f"(bgood r{i} {tname})")
        elif b == "bad":
            belief_facts.append(f"(bbad r{i} {tname})")
        else:
            belief_facts.append(f"(bunk r{i} {tname})")

    final_buckets = [bucket_name(p, good_threshold, bad_threshold) for p in last_row["probs"]]

    return {
        "n_rocks": n_rocks,
        "cells": cells,
        "tapes": tapes,
        "next_links": next_links,
        "last_t": last_t,
        "start_cell": cell_name(rows[0]["x"], rows[0]["y"]),
        "pos_facts": pos_facts,
        "do_facts": do_facts,
        "obs_facts": obs_facts,
        "belief_facts": belief_facts,
        "final_buckets": final_buckets,
    }


def generate_domain_text(domain_name: str, n_rocks: int, final_buckets: List[str]) -> str:
    rock_ids = [f"r{i}" for i in range(1, n_rocks + 1)]

    clear_lines = []
    set_lines = []
    for r in rock_ids:
        clear_lines.extend([
            f"(not (k-good {r}))",
            f"(not (k-not-good {r}))",
            f"(not (k-unk {r}))",
        ])
        set_lines.extend([
            f"(when (bgood {r} ?t) (k-good {r}))",
            f"(when (bbad  {r} ?t) (k-not-good {r}))",
            f"(when (bunk  {r} ?t) (k-unk {r}))",
        ])

    finish_reqs = []
    for i, b in enumerate(final_buckets, start=1):
        if b == "good":
            finish_reqs.append(f"(checked-good r{i})")
        elif b == "bad":
            finish_reqs.append(f"(checked-bad r{i})")
        else:
            finish_reqs.append(f"(checked-unk r{i})")

    return f"""(define (domain {domain_name})
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types cell tape act obs rock)

  (:predicates
    (at ?c - cell)

    (tape-at ?t - tape)
    (next ?t ?tp - tape)
    (last ?t - tape)

    (pos ?c - cell ?t - tape)
    (do ?a - act ?t - tape)
    (obs-at ?o - obs ?t - tape)

    (bgood ?r - rock ?t - tape)
    (bbad  ?r - rock ?t - tape)
    (bunk  ?r - rock ?t - tape)

    (k-good ?r - rock)
    (k-not-good ?r - rock)
    (k-unk ?r - rock)

    (checked-good ?r - rock)
    (checked-bad  ?r - rock)
    (checked-unk  ?r - rock)

    (done)
  )

  (:action policy-step
    :parameters (?t ?tp - tape ?c ?cp - cell ?a - act ?o - obs)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (next ?t ?tp)
      (at ?c)
      (pos ?c ?t)
      (pos ?cp ?tp)
      (do ?a ?t)
      (obs-at ?o ?t)
    )
    :effect (and
      (not (at ?c)) (at ?cp)
      (not (tape-at ?t)) (tape-at ?tp)

      {' '.join(clear_lines)}

      {' '.join(set_lines)}
    )
  )

  (:action check-good
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-good ?r))
    :effect (checked-good ?r)
  )

  (:action check-bad
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-not-good ?r))
    :effect (checked-bad ?r)
  )

  (:action check-unknown
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-unk ?r))
    :effect (checked-unk ?r)
  )

  (:action finish
    :parameters (?t - tape)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (last ?t)
      {' '.join(finish_reqs)}
    )
    :effect (done)
  )
)
"""


def generate_problem_text(problem_name: str, domain_name: str, comp: Dict) -> str:
    cell_line = " ".join(comp["cells"]) + " - cell"
    tape_line = " ".join(comp["tapes"]) + " - tape"
    act_line = " ".join(f"a{i}" for i in range(1, 10)) + " - act"
    obs_line = "o1 o2 o3 - obs"
    rock_line = " ".join(f"r{i}" for i in range(1, comp["n_rocks"] + 1)) + " - rock"

    init_lines = [
        f"(at {comp['start_cell']})",
        "(tape-at t0)",
        *[f"(next {a} {b})" for a, b in comp["next_links"]],
        f"(last {comp['last_t']})",
        *comp["pos_facts"],
        *comp["do_facts"],
        *comp["obs_facts"],
        *comp["belief_facts"],
    ]

    goal_lines = ["(done)"]
    for i, b in enumerate(comp["final_buckets"], start=1):
        if b == "good":
            goal_lines.append(f"(checked-good r{i})")
        elif b == "bad":
            goal_lines.append(f"(checked-bad r{i})")
        else:
            goal_lines.append(f"(checked-unk r{i})")

    return f"""(define (problem {problem_name})
  (:domain {domain_name})

  (:objects
    {cell_line}

    {tape_line}

    {act_line}
    {obs_line}
    {rock_line}
  )

  (:init
    {'\n    '.join(init_lines)}
  )

  (:goal (and
    {'\n    '.join(goal_lines)}
  ))
)
"""


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, type=Path, help="RockSample CSV trace")
    ap.add_argument("--autogen-root", required=True, type=Path, help="Output root")
    ap.add_argument("--subdir", default="rock_sample", help="Output subfolder")
    ap.add_argument("--problem-name", default="rock-policy-belief-run")
    ap.add_argument("--domain-name", default="rock-policy-belief-replay-checkall")
    ap.add_argument("--good-threshold", type=float, default=0.9)
    ap.add_argument("--bad-threshold", type=float, default=0.1)
    args = ap.parse_args()

    if not args.csv.exists():
        raise FileNotFoundError(args.csv)

    out_dir = args.autogen_root / args.subdir
    out_dir.mkdir(parents=True, exist_ok=True)
    idx = next_index(out_dir)

    rows = parse_trace_rows(args.csv)
    comp = build_components(rows, args.good_threshold, args.bad_threshold)

    domain_text = generate_domain_text(args.domain_name, comp["n_rocks"], comp["final_buckets"])
    problem_text = generate_problem_text(args.problem_name, args.domain_name, comp)

    domain_out = out_dir / f"policy_domain_{idx}.pddl"
    problem_out = out_dir / f"policy_problem_{idx}.pddl"

    domain_out.write_text(domain_text, encoding="utf-8")
    problem_out.write_text(problem_text, encoding="utf-8")

    print(f"[OK] wrote: {domain_out}")
    print(f"[OK] wrote: {problem_out}")
    print(f"[OK] rocks detected: {comp['n_rocks']}")
    print(f"[OK] rows parsed: {len(rows)}")


if __name__ == "__main__":
    main()