
;; Storage
(define-map presale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-SALE-NOT-ACTIVE u500)
(define-constant ERR-NO-MINTPASS-REMAINING u501)

;; Define Variables
(define-data-var mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-constant mint-price u50000000)

;; Presale balance
(define-read-only (get-presale-balance (account principal))
  (default-to u0
    (map-get? presale-count account)))

;; Claim a new NFT
(define-public (claim)
  (if (var-get mintpass-sale-active)
    (mintpass-mint tx-sender)
    (public-mint tx-sender)))

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (mintpass-mint (new-owner principal))
  (let ((presale-balance (get-presale-balance new-owner)))
    (asserts! (> presale-balance u0) (err ERR-NO-MINTPASS-REMAINING))
    (map-set presale-count
              new-owner
              (- presale-balance u1))
  (contract-call? .megapont-ape-club-nft mint new-owner)))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) (err ERR-SALE-NOT-ACTIVE))
    (contract-call? .megapont-ape-club-nft mint new-owner)))

;; Set public sale flag
(define-public (flip-mintpass-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  (err ERR-NOT-AUTHORIZED))
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set mintpass-sale-active (not (var-get mintpass-sale-active)))
    (ok (var-get mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    ;; Disable the Mintpass sale
    (var-set mintpass-sale-active false)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

(as-contract (contract-call? .megapont-ape-club-nft set-mint-address))

;; We want to add 500 addresses here on deploy...
;; This exists with safety checks in add-mintpass as we were going to do this for whitelist
;; but could not get this ready in time.
(map-set presale-count 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 u5)
(map-set presale-count 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP u5)
(map-set presale-count 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB u4)