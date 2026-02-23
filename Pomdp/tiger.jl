using POMDPs
using QuickPOMDPs
using POMDPTools: Uniform, SparseCat, Deterministic, stepthrough
using QMDP

locs = ["left", "right"]
ks = 0:7
states_list = [(l, k) for l in locs for k in ks]

m = QuickPOMDP(
    states=states_list,
    actions=["left", "right", "listen"],
    observations=["left", "right"],
    initialstate=Uniform([(l, 0) for l in locs]),
    discount=0.95,
    isterminal=s -> s[2] == 7,
    transition=function (s, a)
        loc, k = s
        if k == 7
            return Deterministic(s)
        end

        if a == "listen"
            return Deterministic((loc, k))
        else
            k2 = min(k + 1, 7)
            return Uniform([(l, k2) for l in locs])
        end
    end,
    observation=function (s, a, sp)
        locp, kp = sp
        if kp == 7
            return Uniform(["left", "right"])
        end

        if a == "listen"
            if locp == "left"
                return SparseCat(["left", "right"], [0.85, 0.15])
            else
                return SparseCat(["right", "left"], [0.85, 0.15])
            end
        else
            return Uniform(["left", "right"])
        end
    end,
    reward=function (s, a)
        loc, k = s
        if k == 7
            return 0.0
        end

        if a == "listen"
            return -1.0
        elseif loc == a
            return -100.0
        else
            return 10.0
        end
    end
)

solver = QMDPSolver()
policy = solve(solver, m)

function belief_lr(m, b)
    pleft = 0.0
    pright = 0.0
    for st in states(m)
        loc, k = st
        p = pdf(b, st)
        if loc == "left"
            pleft += p
        else
            pright += p
        end
    end
    return pleft, pright
end

function run_sim(m, policy; max_steps=50, io=stdout)
    rsum = 0.0
    for (s, b, a, o, r) in stepthrough(m, policy, "s,b,a,o,r", max_steps=max_steps)
        pleft, pright = belief_lr(m, b)

        # Write a CSV-like trace line
        println(io, "TRACE,$(s[2]),$a,$o,$(pleft),$(pright)")

        rsum += r
        if isterminal(m, s)
            break
        end
    end
    return rsum
end

# ---------------------------
# MAIN: write trace to a file
# ---------------------------
trace_path = length(ARGS) >= 1 ? ARGS[1] : "trace.csv"
max_steps = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 50

rsum = 0.0
open(trace_path, "w") do io
    # println(io, "TRACE,k,action,obs,pleft,pright")
    global rsum = run_sim(m, policy, max_steps=max_steps, io=io)
end

println("Wrote trace to: $trace_path")
println("Undiscounted reward was $rsum.")
