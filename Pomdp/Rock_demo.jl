import Pkg;
Pkg.add("Plots");
using POMDPs, POMDPTools
using RockSample, NativeSARSOP
using Printf
using Plots

pomdp = RockSamplePOMDP(
    rocks_positions=[(2, 3), (3, 4), (4, 2), (5, 4)],
    sensor_efficiency=20.0,
    discount_factor=0.95,
    good_rock_reward=20.0
)

policy = solve(SARSOPSolver(precision=1e-3), pomdp)
up = DiscreteUpdater(pomdp)

function rock_marginals(pomdp, b)
    n = length(pomdp.rocks_positions)
    p_good = zeros(Float64, n)

    for (s, p) in weighted_iterator(b)
        rocks = getproperty(s, :rocks)
        for i in 1:n
            if rocks[i]
                p_good[i] += p
            end
        end
    end
    return p_good
end

function agent_xy(s)
    pos = getproperty(s, :pos)
    return pos[1], pos[2]
end

function rock_truth(s)
    return collect(getproperty(s, :rocks))
end

# Collect trace for CSV + plotting
times = Int[]
xs = Int[]
ys = Int[]
actions = Any[]
obs_list = Any[]
rewards = Float64[]
beliefs = Vector{Vector{Float64}}()
truths = Vector{Vector{Bool}}()

out_path = "./Pomdp/rock_policy.csv"
open(out_path, "w") do io
    t = 0
    for (b, s, a, o, r) in stepthrough(pomdp, policy, up, "b,s,a,o,r"; max_steps=30)
        x, y = agent_xy(s)
        pgood = rock_marginals(pomdp, b)
        true_rocks = rock_truth(s)

        # Save for later plotting
        push!(times, t)
        push!(xs, x)
        push!(ys, y)
        push!(actions, a)
        push!(obs_list, o)
        push!(rewards, Float64(r))
        push!(beliefs, copy(pgood))
        push!(truths, copy(true_rocks))

        # CSV
        print(io, "TRACE,$t,$x,$y,$a,$o")
        for i in 1:length(pgood)
            @printf(io, ",%.10f", pgood[i])
        end
        println(io)

        # Console debug
        println("t = $t")
        println("  pos      = ($x,$y)")
        println("  action   = $a")
        println("  obs      = $o")
        println("  reward   = $r")
        println("  true     = ", true_rocks)
        println("  p_good   = ", round.(pgood, digits=4))
        println()

        t += 1
        if isterminal(pomdp, s)
            println("Reached terminal state.")
            break
        end
    end
end

println("Wrote trace to: $out_path")

gif_path = "./Pomdp/rock_policy.gif"
nrocks = length(pomdp.rocks_positions)

anim = @animate for k in 1:length(times)
    t = times[k]
    pgood = beliefs[k]
    true_rocks = truths[k]

    labels = ["R$i" for i in 1:nrocks]
    true_text = ["R$i=" * (true_rocks[i] ? "GOOD" : "BAD/EMPTY") for i in 1:nrocks]

    p = bar(
        labels,
        pgood,
        ylim=(0, 1),
        legend=false,
        title="RockSample belief at t=$t",
        xlabel="Rocks",
        ylabel="P(good)"
    )

    annotate!(1, 0.95, text("pos=($(xs[k]),$(ys[k]))  action=$(actions[k])  obs=$(obs_list[k])", 9))
    annotate!(1, 0.88, text("reward=$(round(rewards[k], digits=3))", 9))

    for i in 1:nrocks
        annotate!(i, 0.08, text(true_text[i], 8))
    end

    p
end

gif(anim, gif_path, fps=1)
println("Wrote GIF to: $gif_path")