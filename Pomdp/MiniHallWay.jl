using POMDPs, POMDPTools, POMDPModels, QMDP
using Random, Printf

function run_minihallway_qmdp_with_beliefs(; max_steps=60, iters=500)


    pomdp = isdefined(POMDPModels, :MiniHallwayPOMDP) ? POMDPModels.MiniHallwayPOMDP() :
            POMDPModels.MiniHallway()

    policy = solve(QMDPSolver(max_iterations=iters), pomdp)
    updater = DiscreteUpdater(pomdp)

    S = collect(states(pomdp))

    println("---- MiniHallway (QMDP) ----")
    t, R = 0, 0.0
    for (b, s, a, o, r) in stepthrough(pomdp, policy, updater, "b,s,a,o,r"; max_steps=max_steps)
        t += 1
        R += r

        # Belief vector aligned with S
        p = [pdf(b, si) for si in S]
        # MAP state for a quick glance
        _, imax = findmax(p)
        map_state = S[imax]

        @printf("t=%2d  a=%s  o=%s  r=%.1f  R=%.1f\n", t, string(a), string(o), r, R)

        # Print full belief
        io = IOBuffer()
        for (i, si) in enumerate(S)
            print(io, string(si), "=>", @sprintf("%.3f", p[i]))
            if i < length(S)
                print(io, ", ")
            end
        end
        println("belief: [", String(take!(io)), "]   MAP=", map_state)

        if isterminal(pomdp, s)
            println("🚩 terminal state reached.")
            break
        end
    end

    println("Note: step rewards are 0 by default; only terminal transitions give a nonzero reward (e.g., +1 at goal).")
    return R
end

run_minihallway_qmdp_with_beliefs()
