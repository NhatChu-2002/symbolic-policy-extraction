(define (problem rock-policy-belief-run)
  (:domain rock-policy-belief-replay-checkall)

  (:objects
    c1_1 c2_1 c2_2 c3_2 c4_2 c4_3 c3_3 c3_4 c4_4 c5_4 - cell

    ;; added t16 so policy-step can apply at t15
    t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 - tape

    a1 a2 a3 a5 a6 a7 a8 a9 - act
    o1 o2 o3 - obs
    r1 r2 r3 r4 - rock
  )

  (:init
    ;; start state
    (at c1_1)
    (tape-at t0)

    ;; tape links (added next t15 t16, last t16)
    (next t0 t1) (next t1 t2) (next t2 t3) (next t3 t4)
    (next t4 t5) (next t5 t6) (next t6 t7) (next t7 t8)
    (next t8 t9) (next t9 t10) (next t10 t11) (next t11 t12)
    (next t12 t13) (next t13 t14) (next t14 t15) (next t15 t16)
    (last t16)

    (pos c1_1 t0)
    (pos c2_1 t1)
    (pos c2_2 t2)
    (pos c2_2 t3)
    (pos c3_2 t4)
    (pos c3_2 t5)
    (pos c4_2 t6)
    (pos c4_2 t7)
    (pos c4_3 t8)
    (pos c4_3 t9)
    (pos c3_3 t10)
    (pos c3_4 t11)
    (pos c3_4 t12)
    (pos c4_4 t13)
    (pos c5_4 t14)
    (pos c5_4 t15)
    (pos c5_4 t16)

    (do a3 t0)
    (do a2 t1)
    (do a6 t2)
    (do a3 t3)
    (do a8 t4)
    (do a3 t5)
    (do a1 t6)
    (do a2 t7)
    (do a7 t8)
    (do a5 t9)
    (do a2 t10)
    (do a1 t11)
    (do a3 t12)
    (do a3 t13)
    (do a9 t14)
    (do a3 t15)
    (do a3 t16)

    (obs-at o3 t0)
    (obs-at o3 t1)
    (obs-at o2 t2)
    (obs-at o3 t3)
    (obs-at o1 t4)
    (obs-at o3 t5)
    (obs-at o3 t6)
    (obs-at o3 t7)
    (obs-at o1 t8)
    (obs-at o3 t9)
    (obs-at o3 t10)
    (obs-at o3 t11)
    (obs-at o3 t12)
    (obs-at o3 t13)
    (obs-at o2 t14)
    (obs-at o3 t15)
    (obs-at o3 t16)

    ;; ----------------------------
    ;; BELIEF BUCKETS
    ;; ----------------------------

    ;; t0
    (bunk r1 t0) (bunk r2 t0) (bunk r3 t0) (bunk r4 t0)
    ;; t1
    (bunk r1 t1) (bunk r2 t1) (bunk r3 t1) (bunk r4 t1)
    ;; t2
    (bunk r1 t2) (bunk r2 t2) (bunk r3 t2) (bunk r4 t2)

    ;; t3
    (bbad r1 t3) (bunk r2 t3) (bunk r3 t3) (bunk r4 t3)
    ;; t4
    (bbad r1 t4) (bunk r2 t4) (bunk r3 t4) (bunk r4 t4)

    ;; t5
    (bbad r1 t5) (bunk r2 t5) (bgood r3 t5) (bunk r4 t5)
    ;; t6
    (bbad r1 t6) (bunk r2 t6) (bgood r3 t6) (bunk r4 t6)

    ;; t7
    (bbad r1 t7) (bunk r2 t7) (bbad r3 t7) (bunk r4 t7)
    ;; t8
    (bbad r1 t8) (bunk r2 t8) (bbad r3 t8) (bunk r4 t8)

    ;; t9
    (bbad r1 t9) (bgood r2 t9) (bbad r3 t9) (bunk r4 t9)
    ;; t10
    (bbad r1 t10) (bgood r2 t10) (bbad r3 t10) (bunk r4 t10)
    ;; t11
    (bbad r1 t11) (bgood r2 t11) (bbad r3 t11) (bunk r4 t11)

    ;; t12
    (bbad r1 t12) (bbad r2 t12) (bbad r3 t12) (bunk r4 t12)
    ;; t13
    (bbad r1 t13) (bbad r2 t13) (bbad r3 t13) (bunk r4 t13)

    ;; t14
    (bbad r1 t14) (bbad r2 t14) (bbad r3 t14) (bunk r4 t14)

    ;; t15
    (bbad r1 t15) (bbad r2 t15) (bbad r3 t15) (bbad r4 t15)

    ;; t16
    (bbad r1 t16) (bbad r2 t16) (bbad r3 t16) (bbad r4 t16)
  )

  (:goal (and
    (done)
    (checked-bad r1)
    (checked-good r2)
    (checked-bad r3)
    (checked-bad r4)
  ))
)