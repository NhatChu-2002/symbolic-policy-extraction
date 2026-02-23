using POMDPs, POMDPTools
using RockSample, NativeSARSOP
using Printf

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

# --- write TRACE lines to a CSV file ---
out_path = "./Pomdp/trace.csv"
open(out_path, "w") do io
    n = length(pomdp.rocks_positions)
    print(io, "TRACE,t,x,y,a,o")
    for i in 1:n
        print(io, ",p_good_$i")
    end
    println(io)

    t = 0
    for (b, s, a, o, r) in stepthrough(pomdp, policy, up, "b,s,a,o,r"; max_steps=30)
        x, y = agent_xy(s)
        pgood = rock_marginals(pomdp, b)

        print(io, "TRACE,$t,$x,$y,$a,$o")
        for i in 1:length(pgood)
            @printf(io, ",%.10f", pgood[i])
        end
        println(io)

        t += 1
        if isterminal(pomdp, s)
            break
        end
    end
end

println("Wrote trace to: $out_path")