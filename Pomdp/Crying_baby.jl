using POMDPs, QuickPOMDPs, POMDPTools, QMDP
using POMDPModels
using Printf

sname(x) = x === true ? :hungry : :not_hungry
aname(x) = x === true ? :feed : :ignore
oname(x) = x === true ? :cry : :quiet

function run_baby(; max_steps=10)
    pomdp = BabyPOMDP()

    solver = QMDPSolver(max_iterations=200)   # you can tweak iterations
    policy = solve(solver, pomdp)

    up = DiscreteUpdater(pomdp)

    println("---- Crying Baby trace (QMDP) ----")
    t = 0
    for (b, s, a, o, r) in stepthrough(pomdp, policy, up, "b,s,a,o,r"; max_steps=max_steps)
        t += 1
        @printf("t=%2d  a=%s  o=%s  r=%6.2f   b: P(hungry)=%.3f  P(not_hungry)=%.3f\n",
            t, string(aname(a)), string(oname(o)), r, pdf(b, true), pdf(b, false))
    end
end

run_baby()
