(define (domain tiger-policy-fsc)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types node tape tag)

  (:predicates
    (at ?n - node)

    (k0) (k1) (k2) (k3) (k4) (k5) (k6)

    (tape-at ?t - tape)
    (next ?t ?tp - tape)
    (obs-left ?t - tape)
    (obs-right ?t - tape)
    (consumed ?t - tape)

    (k-left)
    (k-right)

    (k-not-left)
    (k-not-right)

    (tiger-left ?g - tag)
    (tiger-right ?g - tag)

    (confirmed ?g - tag)

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
        (and
          (not (at b0)) (at bl1)

          (not (k-right)) (k-left)

          (not (k-not-left)) (k-not-right)
        )
      )

      (when (obs-right ?t)
        (and
          (not (at b0)) (at br1)

          ;; set belief = right
          (not (k-left)) (k-right)

          ;; set negative belief: not-left
          (not (k-not-right)) (k-not-left)
        )
      )
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
        (and
          (not (at bl1)) (at bl2)
          (not (k-right)) (k-left)
          (not (k-not-left)) (k-not-right)
        )
      )

      (when (obs-right ?t)
        (and
          (not (at bl1)) (at b0)
          (not (k-left)) (k-right)
          (not (k-not-right)) (k-not-left)
        )
      )
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
        (and
          (not (at bl2)) (at bl3)
          (not (k-right)) (k-left)
          (not (k-not-left)) (k-not-right)
        )
      )

      (when (obs-right ?t)
        (and
          (not (at bl2)) (at bl1)
          (not (k-left)) (k-right)
          (not (k-not-right)) (k-not-left)
        )
      )
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
        (and
          (not (at br1)) (at br2)
          (not (k-left)) (k-right)
          (not (k-not-right)) (k-not-left)
        )
      )

      (when (obs-left ?t)
        (and
          (not (at br1)) (at b0)
          (not (k-right)) (k-left)
          (not (k-not-left)) (k-not-right)
        )
      )
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
        (and
          (not (at br2)) (at br3)
          (not (k-left)) (k-right)
          (not (k-not-right)) (k-not-left)
        )
      )

      (when (obs-left ?t)
        (and
          (not (at br2)) (at br1)
          (not (k-right)) (k-left)
          (not (k-not-left)) (k-not-right)
        )
      )
    )
  )

  (:action pi_open_right_from_bl3
    :precondition (and
      (at bl3)
      (k-left)
      (k-not-right)    
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

      ;; reset beliefs
      (not (k-left)) (not (k-right))
      (not (k-not-left)) (not (k-not-right))
    )
  )

  (:action pi_open_left_from_br3
    :precondition (and
      (at br3)
      (k-right)
      (k-not-left)        
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

      ;; reset beliefs
      (not (k-left)) (not (k-right))
      (not (k-not-left)) (not (k-not-right))
    )
  )


  (:action check-tiger-left
    :parameters (?g - tag)
    :precondition (and
      (not (done))
      (k-left)
      (k-not-right)       
      (tiger-left ?g)
      (not (confirmed ?g))
    )
    :effect (confirmed ?g)
  )

  (:action check-tiger-right
    :parameters (?g - tag)
    :precondition (and
      (not (done))
      (k-right)
      (k-not-left)        
      (tiger-right ?g)
      (not (confirmed ?g))
    )
    :effect (confirmed ?g)
  )

  (:action confirm-all-tags
    :precondition (and (confirmed tagL) (confirmed tagR) (not (tiger-confirmed)))
    :effect (tiger-confirmed)
  )

  (:action finish
    :precondition (k6)
    :effect (done)
  )
)