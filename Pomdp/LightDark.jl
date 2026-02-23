using POMDPs, POMDPModels, POMDPTools
using ParticleFilterTrees
using Random, Printf

pomdp = LightDark1D()

solver = PFTDPWSolver(tree_queries=30_000, check_repeat_obs=false)
planner = solve(solver, pomdp)

up = updater(planner)

Random.seed!(0)
total = 0.0
for (b, s, a, o, r) in stepthrough(pomdp, planner, up, "b,s,a,o,r"; max_steps=30)
    @printf("s=(status=%d, y=%.2f)  a=%d  o~N(%.2f, σ(y))  r=%.1f\n",
        s.status, s.y, a, o)
    total += r
end
println("Undiscounted return: ", total)
