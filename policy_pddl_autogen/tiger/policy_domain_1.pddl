(define (domain tiger-policy-fsc)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types node tape)

  (:predicates
    (at ?n - node)

    (k0) (k1) (k2) (k3) (k4) (k5) (k6)

    (tape-at ?t - tape)
    (next ?t ?tp - tape)

    (obs-left ?t - tape)
    (obs-right ?t - tape)

    (consumed ?t - tape)

    (tiger-left) 
    (tiger-right)

    (k-left)
    (k-right)
    (tiger-confirmed)

    (done)
  )


  (:action pi_listen_b0
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (at b0)
      (tape-at ?t)
      (next ?t ?tp)
      (not (consumed ?t))
      (or (obs-left ?t) (obs-right ?t))
    )
    :effect (and
      (consumed ?t)
      (not (tape-at ?t)) (tape-at ?tp)

      (when (obs-left ?t)
        (and (not (at b0)) (at bl1)
             (not (k-right)) (k-left)))

      (when (obs-right ?t)
        (and (not (at b0)) (at br1)
             (not (k-left)) (k-right)))
    )
  )

  (:action pi_listen_bl1
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (at bl1)
      (tape-at ?t)
      (next ?t ?tp)
      (not (consumed ?t))
      (or (obs-left ?t) (obs-right ?t))
    )
    :effect (and
      (consumed ?t)
      (not (tape-at ?t)) (tape-at ?tp)

      (when (obs-left ?t)
        (and (not (at bl1)) (at bl2)
             (not (k-right)) (k-left)))

      (when (obs-right ?t)
        (and (not (at bl1)) (at b0)
             (not (k-left)) (k-right)))
    )
  )

  (:action pi_listen_bl2
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (at bl2)
      (tape-at ?t)
      (next ?t ?tp)
      (not (consumed ?t))
      (or (obs-left ?t) (obs-right ?t))
    )
    :effect (and
      (consumed ?t)
      (not (tape-at ?t)) (tape-at ?tp)

      (when (obs-left ?t)
        (and (not (at bl2)) (at bl3)
             (not (k-right)) (k-left)))

      (when (obs-right ?t)
        (and (not (at bl2)) (at bl1)
             (not (k-left)) (k-right)))
    )
  )

  (:action pi_listen_br1
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (at br1)
      (tape-at ?t)
      (next ?t ?tp)
      (not (consumed ?t))
      (or (obs-left ?t) (obs-right ?t))
    )
    :effect (and
      (consumed ?t)
      (not (tape-at ?t)) (tape-at ?tp)

      (when (obs-right ?t)
        (and (not (at br1)) (at br2)
             (not (k-left)) (k-right)))

      (when (obs-left ?t)
        (and (not (at br1)) (at b0)
             (not (k-right)) (k-left)))
    )
  )

  (:action pi_listen_br2
    :parameters (?t ?tp - tape)
    :precondition (and
      (not (done))
      (at br2)
      (tape-at ?t)
      (next ?t ?tp)
      (not (consumed ?t))
      (or (obs-left ?t) (obs-right ?t))
    )
    :effect (and
      (consumed ?t)
      (not (tape-at ?t)) (tape-at ?tp)

      (when (obs-right ?t)
        (and (not (at br2)) (at br3)
             (not (k-left)) (k-right)))

      (when (obs-left ?t)
        (and (not (at br2)) (at br1)
             (not (k-right)) (k-left)))
    )
  )

  ;; OPEN actions: unchanged except we no longer mention obs-ready.

  (:action pi_open_right_from_bl3
    :precondition (and
      (at bl3)
      (k-left)
      (not (done))
    )
    :effect (and
      (not (at bl3)) (at b0)

      (when (k0) (and (not (k0)) (k1)))
      (when (k1) (and (not (k1)) (k2)))
      (when (k2) (and (not (k2)) (k3)))
      (when (k3) (and (not (k3)) (k4)))
      (when (k4) (and (not (k4)) (k5)))
      (when (k5) (and (not (k5)) (k6)))

      (not (k-left)) (not (k-right))
    )
  )

  (:action pi_open_left_from_br3
    :precondition (and
      (at br3)
      (k-right)
      (not (done))
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

  (:action check-tiger-left
    :precondition (and (k-left) (tiger-left) (not (done)))
    :effect (tiger-confirmed)
  )

  (:action check-tiger-right
    :precondition (and (k-right) (tiger-right) (not (done)))
    :effect (tiger-confirmed)
  )

  (:action finish
    :precondition (k6)
    :effect (done)
  )
)