### POMDP Policy to PDDL (Work in Progress)

This repository contains experimental code for generating classical PDDL models from policies produced by Julia POMDP solvers.

The current pipeline focuses on:

Running a POMDP policy in Julia

Exporting an execution trace

Converting that trace into a PDDL domain and problem file

The goal is to enable symbolic analysis (e.g., landmark extraction) of probabilistic policies.