(define (problem tiger-policy-run)
  (:domain tiger-policy-fsc)

  (:objects
    b0 bl1 bl2 bl3 br1 br2 br3 - node
    t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 - tape
  )

  (:init
    (at b0)
    (k0)

    (oneof (tiger-left) (tiger-right))

    (tape-at t0)
    (next t0 t1) (next t1 t2) (next t2 t3) (next t3 t4) (next t4 t5)
    (next t5 t6) (next t6 t7) (next t7 t8) (next t8 t9)

    (obs-left  t0)
    (obs-right t1)
    (obs-right t2)
    (obs-right t3)
    (obs-left  t4)
    (obs-left  t5)
    (obs-right t6)
    (obs-left  t7)
    (obs-right t8)
    (obs-left  t9)
  )

  (:goal (done))
)