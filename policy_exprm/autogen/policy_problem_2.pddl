(define (problem tiger-policy-run)
  (:domain tiger-policy-fsc)

  (:objects
    B0 BL1 BL2 BL3 BR1 BR2 BR3 - node
    t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 - tape
  )

  (:init
    ;; controller start
    (at B0)

    ;; counter start
    (k0)

    ;; belief start
    (b-unk)

    ;; tape head
    (tape-at t0)

    ;; tape successor chain
    (next t0 t1) (next t1 t2) (next t2 t3) (next t3 t4) (next t4 t5) (next t5 t6) (next t6 t7) (next t7 t8) (next t8 t9) (next t9 t10) (next t10 t11) (next t11 t12) (next t12 t13) (next t13 t14) (next t14 t15) (next t15 t16) (next t16 t17) (next t17 t18) (next t18 t19) (next t19 t20) (next t20 t21) (next t21 t22) (next t22 t23) (next t23 t24) (next t24 t25) (next t25 t26) (next t26 t27) (next t27 t28) (next t28 t29) (next t29 t30) (next t30 t31) (next t31 t32) (next t32 t33) (next t33 t34) (next t34 t35)

    ;; observations 
    (obs-left t0) (obs-left t1) (obs-right t2) (obs-right t3) (obs-right t4) (obs-right t5) (obs-right t6) (obs-left t7) (obs-left t8) (obs-right t9) (obs-left t10) (obs-left t11) (obs-right t12) (obs-left t13) (obs-left t14) (obs-right t15) (obs-left t16) (obs-left t17) (obs-right t18) (obs-left t19) (obs-right t20) (obs-left t21) (obs-left t22) (obs-right t23) (obs-left t24) (obs-left t25) (obs-left t26) (obs-left t27) (obs-right t28) (obs-right t29) (obs-right t30) (obs-left t31) (obs-right t32) (obs-right t33) (obs-right t34) (obs-right t35)

    ;; mark open steps as already consumed 
    (consumed t2) (consumed t5) (consumed t15) (consumed t23) (consumed t27) (consumed t31) (consumed t35)
  )

  (:goal (done))
)
