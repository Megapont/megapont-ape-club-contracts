;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)

;; define a new NFT. Make sure to replace Megapont-Ape-Club
(define-non-fungible-token Megapont-Ape-Club uint)

;; Storage
(define-map token-count { owner: principal } { count: int })
(define-map presale-count { owner: principal } { count: uint })

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-SALE-NOT-ACTIVE u500)
(define-constant ERR-NO-MINTPASS-REMAINING u501)
(define-constant ERR-MINTPASS-EXISTS u502)
(define-constant ERR-SOLD-OUT u300)
(define-constant APE-LIMIT u2500)
(define-constant PRESALE-LIMIT 5)
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
(define-data-var mint-price uint u50000000)
(define-data-var base-uri (string-ascii 80) "ipfs://Qmad43sssgNbG9TpC6NfeiTi9X6f9vPYuzgW2S19BEi49m/")
(define-data-var contract-uri (string-ascii 80) "ipfs://QmSeXmYpkaxvH3xv8ikwDodJZjp9pqxooVvqLHq3Gvg6So")
(define-data-var presale-size uint u0)


;; Token count for account
(define-private (balance-of (account principal))
  (default-to 0
    (get count
      (map-get? token-count {owner: account})
    )
  )
)

;; Presale balance
(define-private (presale-balance-of (account principal))
  (default-to u0
    (get count
      (map-get? presale-count {owner: account})
    )
  )
)

;; Claim a new NFT
(define-public (claim)
  (if (is-eq true (var-get mintpass-sale-active))
    (mintpass-mint tx-sender)
    (public-mint tx-sender)))

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)
  )
)

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)
  )
)

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)
  )
)

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)
  )
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? Megapont-Ape-Club token-id sender recipient)
        success
        (let
        ((sender-balance (balance-of sender))
        (recipient-balance (balance-of recipient)))
        (begin
        (map-set token-count
              {owner: sender}
              {count: (+ 1 sender-balance)}
            )
        (map-set token-count
              {owner: recipient}
              {count: (+ 1 recipient-balance)}
            )
        (ok success)))
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace Megapont-Ape-Club
  (ok (nft-get-owner? Megapont-Ape-Club token-id)))

(define-read-only (mintpass-balance-of (account principal))
  ;; Make sure to replace Megapont-Ape-Club
  (ok (presale-balance-of account)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (var-get base-uri) (uint-to-string token-id)))))


(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

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
            (try! (stx-transfer? u2500000 tx-sender WALLET_3))
            (try! (stx-transfer? u1250000 tx-sender WALLET_4))
            (var-set last-id next-id)
            (map-set token-count
              {owner: new-owner}
              {count: (+ 1 current-balance)}
            )
            (ok true)))
        error (err error))))

;; Internal - Mint new NFT
(define-private (mint-presale (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (< (var-get last-id) APE-LIMIT) (err ERR-SOLD-OUT))
      (match (nft-mint? Megapont-Ape-Club next-id new-owner)
        success
        (let
        ((current-balance (balance-of new-owner)))
          (begin
            (try! (stx-transfer? u24000000 tx-sender WALLET_1))
            (try! (stx-transfer? u22500000 tx-sender WALLET_2))
            (try! (stx-transfer? u2500000 tx-sender WALLET_3))
            (try! (stx-transfer? u1250000 tx-sender WALLET_4))
            (var-set last-id next-id)
            (map-set token-count
              {owner: new-owner}
              {count: (+ 1 current-balance)}
            )
            (map-set presale-count
              {owner: new-owner}
              {count: (- (presale-balance-of new-owner) u1)}
            )
            (ok true)))
        error (err error))))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (mintpass-mint (new-owner principal))
  (let
  ((presale-balance (presale-balance-of new-owner)))
  (if (is-none (map-get? presale-count {owner: new-owner}))
    (err ERR-NO-MINTPASS-REMAINING)
    (if (> presale-balance u0) (mint-presale new-owner)
    (err ERR-NO-MINTPASS-REMAINING)
  ))))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (if (is-eq true (var-get sale-active))
    (mint new-owner) (err ERR-SALE-NOT-ACTIVE)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (if (is-eq true (var-get metadata-frozen))
    (begin
      (var-set base-uri new-base-uri)
      (ok true)
    ) (err METADATA-FROZEN))
    (err ERR-NOT-AUTHORIZED)))

;; Set public sale flag
(define-public (flip-mintpass-sale)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (begin
      ;; Disable the Public sale
      (var-set sale-active false)
      (var-set mintpass-sale-active (if (is-eq true (var-get mintpass-sale-active)) false true))
      (ok (var-get mintpass-sale-active))
    )
    (err ERR-NOT-AUTHORIZED)))

;; Set public sale flag
(define-public (flip-sale)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (begin
      ;; Disable the Mintpass sale
      (var-set mintpass-sale-active false)
      (var-set sale-active (if (is-eq true (var-get sale-active)) false true))
      (ok (var-get sale-active))
    )
    (err ERR-NOT-AUTHORIZED)))

;; Freeze metadata
(define-public (freeze-metadata)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (begin
      (var-set metadata-frozen true)
      (ok (var-get metadata-frozen))
    )
    (err ERR-NOT-AUTHORIZED)))

;; Add address to presale
;;(define-public (add-mintpass (address principal))
;;  (if (is-eq tx-sender CONTRACT-OWNER)
;;      (begin
;;      (if (is-none (map-get? presale-count {owner: address}))
;;      (let
;;        ((current-presale-size (var-get presale-size)))
;;      (begin
;;      (if (< current-presale-size u500)
;;      (ok
;;          (begin
;;            (map-set presale-count
;;              {owner: address}
;;              {count: u5}
;;            )
;;            (var-set presale-size (+ u1 current-presale-size))
;;            )
;;      ) (err PRESALE-CAPACITY))
;;    )) (err ERR-MINTPASS-EXISTS)))
;;    (err ERR-NOT-AUTHORIZED)))

(define-constant LIST_40 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))

(define-private (uint-to-string (value uint))
  (get return (fold uint-to-string-clojure LIST_40 {value: value, return: ""}))
)

(define-private (uint-to-string-clojure (i bool) (data {value: uint, return: (string-ascii 40)}))
  (if (> (get value data) u0)
    {
      value: (/ (get value data) u10),
      return: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get value data) u10))) (get return data)) u40))
    }
    data
  )
)

;; We want to add 500 addresses here on deploy...
;; This exists with safety checks in add-mintpass as we were going to do this for whitelist
;; but could not get this ready in time.
(map-set presale-count {owner: 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6} {count: u5})
(map-set presale-count {owner: 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP} {count: u5})
