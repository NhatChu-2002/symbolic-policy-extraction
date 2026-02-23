(define (domain tiger-policy-fsc)
  (:requirements :strips :adl :negative-preconditions :typing)

  (:types node tape)

  (:predicates
    
    (at ?n - node)

    ;; door-open counter 
    (k0) (k1) (k2) (k3) (k4) (k5) (k6)

    ;; tape head + successor relation
    (tape-at ?t - tape)
    (next ?t ?tp - tape)

    ;; observation
    (obs-left ?t - tape)
    (obs-right ?t - tape)

    ;; bookkeeping:
    ;; - each tape cell can be loaded once
    ;; - after loading, policy must consume the obs before time advances
    (consumed ?t - tape)
    (obs-ready)

    ;; current observation 
    (cur-left)
    (cur-right)

    ;; -------------------------
    ;; belief abstraction:
    ;;   unknown
    ;;   left-weak, left-strong
    ;;   right-weak, right-strong
    ;; -------------------------
    (b-unk)
    (bL-weak) (bL-strong)
    (bR-weak) (bR-strong)

    (belief-weak-enough)

    ;; goal marker
    (done)
  )

  ;; ============================================================
  ;; Load current observation from current tape cell ONCE
  ;; ============================================================
  (:action load-cur-obs
    :parameters (?t - tape)
    :precondition (and
      (not (done))
      (tape-at ?t)
      (not (consumed ?t))
      (not (obs-ready))
    )
    :effect (and
      ;; reset current symbol
      (not (cur-left)) (not (cur-right))

      ;; set from tape cell
      (when (obs-left ?t)  (cur-left))
      (when (obs-right ?t) (cur-right))

      ;; mark loaded/ready
      (consumed ?t)
      (obs-ready)
    )
  )

  ;; ============================================================
  ;; Advance time: only after the policy used the loaded obs
  ;; ============================================================
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

  ;; ============================================================
  ;; FSC policy transitions:
  ;; - must consume obs-ready
  ;; - update belief deterministically to weak/strong
  ;;
  ;; Belief update rule used here:
  ;;   On LEFT observation:
  ;;     if already left-weak or left-strong -> left-strong
  ;;     else -> left-weak
  ;;   On RIGHT observation:
  ;;     if already right-weak or right-strong -> right-strong
  ;;     else -> right-weak
  ;;
  ;; We also set (belief-weak-enough) on every observation consumption.
  ;; ============================================================

  ;; -------------------------
  ;; B0: listen -> branch on current obs
  ;; -------------------------
  (:action pi_listen_B0_left
    :parameters ()
    :precondition (and (at B0) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at B0)) (at BL1)

      ;; clear all belief atoms (evaluated AFTER conditions, but conditions
      ;; in WHEN are evaluated on the pre-state)
      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      ;; set new belief based on pre-state
      (when (bL-weak)   (bL-strong))
      (when (bL-strong) (bL-strong))
      (when (bR-weak)   (bL-weak))
      (when (bR-strong) (bL-weak))
      (when (b-unk)     (bL-weak))

      ;; landmark hook: opening requires this single fact
      (belief-weak-enough)

      ;; consume observation
      (not (obs-ready))
    )
  )

  (:action pi_listen_B0_right
    :parameters ()
    :precondition (and (at B0) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at B0)) (at BR1)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bR-weak)   (bR-strong))
      (when (bR-strong) (bR-strong))
      (when (bL-weak)   (bR-weak))
      (when (bL-strong) (bR-weak))
      (when (b-unk)     (bR-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  ;; -------------------------
  ;; BL1
  ;; -------------------------
  (:action pi_listen_BL1_left
    :parameters ()
    :precondition (and (at BL1) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at BL1)) (at BL2)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bL-weak)   (bL-strong))
      (when (bL-strong) (bL-strong))
      (when (bR-weak)   (bL-weak))
      (when (bR-strong) (bL-weak))
      (when (b-unk)     (bL-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  (:action pi_listen_BL1_right
    :parameters ()
    :precondition (and (at BL1) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at BL1)) (at B0)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bR-weak)   (bR-strong))
      (when (bR-strong) (bR-strong))
      (when (bL-weak)   (bR-weak))
      (when (bL-strong) (bR-weak))
      (when (b-unk)     (bR-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  ;; -------------------------
  ;; BL2
  ;; -------------------------
  (:action pi_listen_BL2_left
    :parameters ()
    :precondition (and (at BL2) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at BL2)) (at BL3)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bL-weak)   (bL-strong))
      (when (bL-strong) (bL-strong))
      (when (bR-weak)   (bL-weak))
      (when (bR-strong) (bL-weak))
      (when (b-unk)     (bL-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  (:action pi_listen_BL2_right
    :parameters ()
    :precondition (and (at BL2) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at BL2)) (at BL1)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bR-weak)   (bR-strong))
      (when (bR-strong) (bR-strong))
      (when (bL-weak)   (bR-weak))
      (when (bL-strong) (bR-weak))
      (when (b-unk)     (bR-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  ;; -------------------------
  ;; BR1 (symmetric)
  ;; -------------------------
  (:action pi_listen_BR1_right
    :parameters ()
    :precondition (and (at BR1) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at BR1)) (at BR2)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bR-weak)   (bR-strong))
      (when (bR-strong) (bR-strong))
      (when (bL-weak)   (bR-weak))
      (when (bL-strong) (bR-weak))
      (when (b-unk)     (bR-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  (:action pi_listen_BR1_left
    :parameters ()
    :precondition (and (at BR1) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at BR1)) (at B0)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bL-weak)   (bL-strong))
      (when (bL-strong) (bL-strong))
      (when (bR-weak)   (bL-weak))
      (when (bR-strong) (bL-weak))
      (when (b-unk)     (bL-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  ;; -------------------------
  ;; BR2
  ;; -------------------------
  (:action pi_listen_BR2_right
    :parameters ()
    :precondition (and (at BR2) (cur-right) (obs-ready) (not (done)))
    :effect (and
      (not (at BR2)) (at BR3)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bR-weak)   (bR-strong))
      (when (bR-strong) (bR-strong))
      (when (bL-weak)   (bR-weak))
      (when (bL-strong) (bR-weak))
      (when (b-unk)     (bR-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  (:action pi_listen_BR2_left
    :parameters ()
    :precondition (and (at BR2) (cur-left) (obs-ready) (not (done)))
    :effect (and
      (not (at BR2)) (at BR1)

      (not (b-unk))
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))

      (when (bL-weak)   (bL-strong))
      (when (bL-strong) (bL-strong))
      (when (bR-weak)   (bL-weak))
      (when (bR-strong) (bL-weak))
      (when (b-unk)     (bL-weak))

      (belief-weak-enough)
      (not (obs-ready))
    )
  )

  ;; ============================================================
  ;; Commit/open actions:
  ;; - ONLY way to increment k
  ;; - REQUIRE belief-weak-enough so it shows up in fact landmarks
  ;; - REQUIRE correct side belief (left or right, weak or strong)
  ;; ============================================================

  (:action pi_open_right_from_BL3
    :parameters ()
    :precondition (and
      (at BL3)
      (belief-weak-enough)
      (or (bL-weak) (bL-strong))   ;; tiger believed on LEFT => open RIGHT
      (not (done))
      (not (obs-ready))
    )
    :effect (and
      (not (at BL3)) (at B0)

      ;; increment k
      (when (k0) (and (not (k0)) (k1)))
      (when (k1) (and (not (k1)) (k2)))
      (when (k2) (and (not (k2)) (k3)))
      (when (k3) (and (not (k3)) (k4)))
      (when (k4) (and (not (k4)) (k5)))
      (when (k5) (and (not (k5)) (k6)))

      ;; reset belief after opening
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))
      (b-unk)
      (not (belief-weak-enough))
    )
  )

  (:action pi_open_left_from_BR3
    :parameters ()
    :precondition (and
      (at BR3)
      (belief-weak-enough)
      (or (bR-weak) (bR-strong))   ;; tiger believed on RIGHT => open LEFT
      (not (done))
      (not (obs-ready))
    )
    :effect (and
      (not (at BR3)) (at B0)

      ;; increment k
      (when (k0) (and (not (k0)) (k1)))
      (when (k1) (and (not (k1)) (k2)))
      (when (k2) (and (not (k2)) (k3)))
      (when (k3) (and (not (k3)) (k4)))
      (when (k4) (and (not (k4)) (k5)))
      (when (k5) (and (not (k5)) (k6)))

      ;; reset belief after opening
      (not (bL-weak)) (not (bL-strong))
      (not (bR-weak)) (not (bR-strong))
      (b-unk)
      (not (belief-weak-enough))
    )
  )

  ;; ============================================================
  ;; Finish
  ;; ============================================================
  (:action finish
    :parameters ()
    :precondition (k6)
    :effect (done)
  )
)
