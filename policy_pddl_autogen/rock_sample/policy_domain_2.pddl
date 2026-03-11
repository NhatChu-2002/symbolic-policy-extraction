(define (domain rock-policy-belief-replay-checkall)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types cell tape act obs rock)

  (:predicates
    (at ?c - cell)

    (tape-at ?t - tape)
    (next ?t ?tp - tape)
    (last ?t - tape)

    (pos ?c - cell ?t - tape)
    (do ?a - act ?t - tape)
    (obs-at ?o - obs ?t - tape)

    (bgood ?r - rock ?t - tape)
    (bbad  ?r - rock ?t - tape)
    (bunk  ?r - rock ?t - tape)

    (k-good ?r - rock)
    (k-not-good ?r - rock)
    (k-unk ?r - rock)

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
      (not (at ?c)) (at ?cp)
      (not (tape-at ?t)) (tape-at ?tp)

      (not (k-good r1)) (not (k-not-good r1)) (not (k-unk r1)) (not (k-good r2)) (not (k-not-good r2)) (not (k-unk r2)) (not (k-good r3)) (not (k-not-good r3)) (not (k-unk r3))

      (when (bgood r1 ?t) (k-good r1)) (when (bbad  r1 ?t) (k-not-good r1)) (when (bunk  r1 ?t) (k-unk r1)) (when (bgood r2 ?t) (k-good r2)) (when (bbad  r2 ?t) (k-not-good r2)) (when (bunk  r2 ?t) (k-unk r2)) (when (bgood r3 ?t) (k-good r3)) (when (bbad  r3 ?t) (k-not-good r3)) (when (bunk  r3 ?t) (k-unk r3))
    )
  )

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
      (checked-bad r1) (checked-bad r2) (checked-bad r3)
    )
    :effect (done)
  )
)
