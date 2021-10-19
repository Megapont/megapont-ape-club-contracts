;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)

;; define a new NFT. Make sure to replace Megapont-Ape-Club
(define-non-fungible-token Megapont-Ape-Club uint)

;; Storage
(define-map token-count principal int)
(define-map presale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-SALE-NOT-ACTIVE u500)
(define-constant ERR-NO-MINTPASS-REMAINING u501)
(define-constant ERR-MINTPASS-EXISTS u502)
(define-constant ERR-SOLD-OUT u300)
(define-constant APE-LIMIT u2500)
(define-constant PRESALE-CAPACITY u504)
(define-constant METADATA-FROZEN u505)

;; Withdraw wallets
;; Megapont 1
(define-constant WALLET_1 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
;; Megapont 2
(define-constant WALLET_2 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
;; Megapont 3
(define-constant WALLET_3 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC)
;; Security Audit
(define-constant WALLET_4 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var mintpass-sale-active bool false)
(define-data-var metadata-frozen bool false)
(define-data-var sale-active bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://Qmad43sssgNbG9TpC6NfeiTi9X6f9vPYuzgW2S19BEi49m/{id}")
(define-constant mint-price u50000000)
(define-constant contract-uri "ipfs://QmSeXmYpkaxvH3xv8ikwDodJZjp9pqxooVvqLHq3Gvg6So")

;; Token count for account
(define-private (balance-of (account principal))
  (default-to 0
    (map-get? token-count account)))

;; Presale balance
(define-read-only (presale-balance-of (account principal))
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

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (match (nft-transfer? Megapont-Ape-Club token-id sender recipient)
      success
        (let
          ((sender-balance (balance-of sender))
          (recipient-balance (balance-of recipient)))
            (map-set token-count
                  sender
                  (- sender-balance 1))
            (map-set token-count
                  recipient
                  (+ 1 recipient-balance))
            (ok success))
      error (err error))))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace Megapont-Ape-Club
  (ok (nft-get-owner? Megapont-Ape-Club token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (< (var-get last-id) APE-LIMIT) (err ERR-SOLD-OUT))
      (match (nft-mint? Megapont-Ape-Club next-id new-owner)
        success
        (let
        ((current-balance (balance-of new-owner)))
          (begin
            (try! (stx-transfer? u24000000 tx-sender WALLET_1))
            (try! (stx-transfer? u22500000 tx-sender WALLET_2))
            (try! (stx-transfer?  u2500000 tx-sender WALLET_3))
            (try! (stx-transfer?  u1000000 tx-sender WALLET_4))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ 1 current-balance)
            )
            (ok true)))
        error (err error))))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (mintpass-mint (new-owner principal))
  (let ((presale-balance (presale-balance-of new-owner)))
    (asserts! (> presale-balance u0) (err ERR-NO-MINTPASS-REMAINING))
    (map-set presale-count
              new-owner
              (- presale-balance u1))
    (mint new-owner)))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) (err ERR-SALE-NOT-ACTIVE))
    (mint new-owner)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err METADATA-FROZEN))
    (var-set base-uri new-base-uri)
    (ok true)))

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

;; Freeze metadata
(define-public (freeze-metadata)  
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; We want to add 500 addresses here on deploy...
;; This exists with safety checks in add-mintpass as we were going to do this for whitelist
;; but could not get this ready in time.
(map-set presale-count 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 u5)
(map-set presale-count 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP u5)
(map-set presale-count 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB u4)