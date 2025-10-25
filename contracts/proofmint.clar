;; ProofMint - Decentralized Badge & Reputation System
;; Version: v1.0
;; Description: Enables DAOs or communities to issue non-transferable badges on-chain.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS & ERRORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-ADMIN (err u100))
(define-constant ERR-BADGE-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-OWNED (err u102))
(define-constant ERR-NOT-OWNER (err u103))
(define-constant ERR-NOT-ISSUER (err u104))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA STRUCTURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var admin principal tx-sender)
(define-map issuers {issuer: principal} {authorized: bool})

;; badge-id -> badge info
(define-map badges
  {badge-id: uint}
  {
    name: (string-ascii 32),
    description: (string-ascii 100),
    uri: (string-ascii 100),
    issuer: principal
  }
)

;; badge-id + owner -> ownership record
(define-map ownerships
  {badge-id: uint, owner: principal}
  {active: bool}
)

(define-data-var badge-counter uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ADMIN & ISSUER CONTROLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (add-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (map-set issuers {issuer: issuer} {authorized: true})
    (print {event: "issuer-added", issuer: issuer})
    (ok true)
  )
)

(define-public (remove-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (map-delete issuers {issuer: issuer})
    (print {event: "issuer-removed", issuer: issuer})
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BADGE CREATION & MINTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (create-badge (name (string-ascii 32)) (description (string-ascii 100)) (uri (string-ascii 100)))
  (let ((issuer-info (map-get? issuers {issuer: tx-sender})))
    (begin
      (asserts! (is-some issuer-info) ERR-NOT-ISSUER)
      (let ((id (+ (var-get badge-counter) u1)))
        (begin
          (map-set badges {badge-id: id}
            {
              name: name,
              description: description,
              uri: uri,
              issuer: tx-sender
            })
          (var-set badge-counter id)
          (print {event: "badge-created", badge-id: id, issuer: tx-sender})
          (ok id)
        )
      )
    )
  )
)

(define-public (mint-badge (badge-id uint) (recipient principal))
  (let (
        (badge (unwrap! (map-get? badges {badge-id: badge-id}) ERR-BADGE-NOT-FOUND))
        ;; Fixed: Changed 'map-get' to 'map-get?' to properly handle optional returns
        (issuer-info (map-get? issuers {issuer: tx-sender}))
      )
    (begin
      (asserts! (is-some issuer-info) ERR-NOT-ISSUER)
      (asserts! (is-none (map-get? ownerships {badge-id: badge-id, owner: recipient})) ERR-ALREADY-OWNED)
      (map-set ownerships {badge-id: badge-id, owner: recipient} {active: true})
      (print {event: "badge-minted", badge-id: badge-id, to: recipient})
      (ok true)
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BADGE REVOCATION (OPTIONAL)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (revoke-badge (badge-id uint) (holder principal))
  (let ((badge (unwrap! (map-get? badges {badge-id: badge-id}) ERR-BADGE-NOT-FOUND)))
    (begin
      (asserts! (is-eq tx-sender (get issuer badge)) ERR-NOT-ISSUER)
      (map-delete ownerships {badge-id: badge-id, owner: holder})
      (print {event: "badge-revoked", badge-id: badge-id, holder: holder})
      (ok true)
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ-ONLY FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-badge (badge-id uint))
  (map-get? badges {badge-id: badge-id})
)

(define-read-only (get-badge-owner (badge-id uint) (owner principal))
  (map-get? ownerships {badge-id: badge-id, owner: owner})
)

(define-read-only (get-total-badges)
  (var-get badge-counter)
)

(define-read-only (has-badge? (owner principal) (badge-id uint))
  (is-some (map-get? ownerships {badge-id: badge-id, owner: owner}))
)
