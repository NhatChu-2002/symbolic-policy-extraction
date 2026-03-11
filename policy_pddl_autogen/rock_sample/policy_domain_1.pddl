(define (domain rock-policy-belief-replay-checkall)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types cell tape act obs rock)

  (:predicates
    ;; physical
    (at ?c - cell)

    ;; tape control
    (tape-at ?t - tape)
    (next ?t ?tp - tape)
    (last ?t - tape)

    ;; recorded trace data (from CSV)
    (pos ?c - cell ?t - tape)
    (do ?a - act ?t - tape)
    (obs-at ?o - obs ?t - tape)

    ;; belief labels stored on tape (derived from p_good)
    (bgood ?r - rock ?t - tape)
    (bbad  ?r - rock ?t - tape)
    (bunk  ?r - rock ?t - tape)

    ;; current policy belief state
    (k-good ?r - rock)
    (k-not-good ?r - rock)
    (k-unk ?r - rock)

    ;; typed evidence (avoids OR-choice)
    (checked-good ?r - rock)
    (checked-bad  ?r - rock)
    (checked-unk  ?r - rock)

    (done)
  )

  (:action policy-step
    :parameters (?t ?tp - tape ?c ?cp - cell ?a - act ?o - obs)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (next ?t ?tp)
      (at ?c)
      (pos ?c ?t)
      (pos ?cp ?tp)
      (do ?a ?t)
      (obs-at ?o ?t)
    )
    :effect (and
      ;; move along recorded trajectory
      (not (at ?c)) (at ?cp)
      (not (tape-at ?t)) (tape-at ?tp)

      ;; clear previous beliefs
      (forall (?r - rock)
        (and (not (k-good ?r))
             (not (k-not-good ?r))
             (not (k-unk ?r))))

      ;; set beliefs for this step from tape labels at time t
      (forall (?r - rock)
        (and
          (when (bgood ?r ?t) (k-good ?r))
          (when (bbad  ?r ?t) (k-not-good ?r))
          (when (bunk  ?r ?t) (k-unk ?r))))
    )
  )

  ;; check actions (belief-dependent)
  (:action check-good
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-good ?r))
    :effect (checked-good ?r)
  )

  (:action check-bad
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-not-good ?r))
    :effect (checked-bad ?r)
  )

  (:action check-unknown
    :parameters (?r - rock)
    :precondition (and (not (done)) (k-unk ?r))
    :effect (checked-unk ?r)
  )

  (:action finish
    :parameters (?t - tape)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (last ?t)

      (checked-bad r1)
      (checked-good r2)
      (checked-bad r3)
      (checked-bad r4)
    )
    :effect (done)
  )
)