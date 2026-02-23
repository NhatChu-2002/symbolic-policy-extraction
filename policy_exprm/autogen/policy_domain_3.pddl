(define (domain tiger-policy-fsc)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types node tape)

  (:predicates
    ;; controller node
    (at ?n - node)

    (k0) (k1) (k2) (k3) (k4) (k5) (k6)

    (tape-at ?t - tape)
    (next ?t ?tp - tape)

    (obs-left ?t - tape)
    (obs-right ?t - tape)

    ;; bookkeeping
    (consumed ?t - tape)
    (obs-ready)

    (cur-left)
    (cur-right)

    (tiger-left)
    (tiger-right)

    (k-left)
    (k-right)

    (done)
  )

  (:action load-cur-obs
    :parameters (?t - tape)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (not (consumed ?t))
      (not (obs-ready))
    )
    :effect (and
      (not (cur-left)) (not (cur-right))
      (when (obs-left ?t)  (cur-left))
      (when (obs-right ?t) (cur-right))
      (consumed ?t)
      (obs-ready)
    )
  )

  (:action advance-tape
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (next ?t ?tp)
      (not (obs-ready))
    )
    :effect (and
      (not (tape-at ?t))
      (tape-at ?tp)
    )
  )

  (:action pi_listen_b0_left
    :precondition (and (at b0) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at b0)) (at bl1)
      ;; set knowledge based on observation (trusted)
      (not (k-right)) (k-left)
      (not (obs-ready))
    )
  )

  (:action pi_listen_b0_right
    :precondition (and (at b0) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at b0)) (at br1)
      (not (k-left)) (k-right)
      (not (obs-ready))
    )
  )

  (:action pi_listen_bl1_left
    :precondition (and (at bl1) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at bl1)) (at bl2)
      (not (k-right)) (k-left)
      (not (obs-ready))
    )
  )

  (:action pi_listen_bl1_right
    :precondition (and (at bl1) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at bl1)) (at b0)
      (not (k-left)) (k-right)
      (not (obs-ready))
    )
  )

  (:action pi_listen_bl2_left
    :precondition (and (at bl2) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at bl2)) (at bl3)
      (not (k-right)) (k-left)
      (not (obs-ready))
    )
  )

  (:action pi_listen_bl2_right
    :precondition (and (at bl2) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at bl2)) (at bl1)
      (not (k-left)) (k-right)
      (not (obs-ready))
    )
  )

  (:action pi_listen_br1_right
    :precondition (and (at br1) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at br1)) (at br2)
      (not (k-left)) (k-right)
      (not (obs-ready))
    )
  )

  (:action pi_listen_br1_left
    :precondition (and (at br1) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at br1)) (at b0)
      (not (k-right)) (k-left)
      (not (obs-ready))
    )
  )

  (:action pi_listen_br2_right
    :precondition (and (at br2) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at br2)) (at br3)
      (not (k-left)) (k-right)
      (not (obs-ready))
    )
  )

  (:action pi_listen_br2_left
    :precondition (and (at br2) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at br2)) (at br1)
      (not (k-right)) (k-left)
      (not (obs-ready))
    )
  )


  (:action pi_open_right_from_bl3
    :precondition (and
      (at bl3)
      (k-left)            ;; know tiger is left => open right
      (not (done))
      (not (obs-ready))
    )
    :effect (and
      (not (at bl3)) (at b0)

      (when (k0) (and (not (k0)) (k1)))
      (when (k1) (and (not (k1)) (k2)))
      (when (k2) (and (not (k2)) (k3)))
      (when (k3) (and (not (k3)) (k4)))
      (when (k4) (and (not (k4)) (k5)))
      (when (k5) (and (not (k5)) (k6)))

      ;; after opening, forget (back to unknown)
      (not (k-left)) (not (k-right))
    )
  )

  (:action pi_open_left_from_br3
    :precondition (and
      (at br3)
      (k-right)           ;; know tiger is right => open left
      (not (done))
      (not (obs-ready))
    )
    :effect (and
      (not (at br3)) (at b0)

      (when (k0) (and (not (k0)) (k1)))
      (when (k1) (and (not (k1)) (k2)))
      (when (k2) (and (not (k2)) (k3)))
      (when (k3) (and (not (k3)) (k4)))
      (when (k4) (and (not (k4)) (k5)))
      (when (k5) (and (not (k5)) (k6)))

      (not (k-left)) (not (k-right))
    )
  )

  (:action finish
    :precondition (k6)
    :effect (done)
  )
)