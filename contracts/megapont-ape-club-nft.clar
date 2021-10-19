;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)

;; define a new NFT. Make sure to replace Megapont-Ape-Club
(define-non-fungible-token Megapont-Ape-Club uint)

;; Storage
(define-map token-count principal int)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant APE-LIMIT u2500)

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
(define-data-var base-uri (string-ascii 80) "ipfs://Qmad43sssgNbG9TpC6NfeiTi9X6f9vPYuzgW2S19BEi49m/{id}")
(define-constant contract-uri "ipfs://QmSeXmYpkaxvH3xv8ikwDodJZjp9pqxooVvqLHq3Gvg6So")
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (balance-of (account principal))
  (default-to 0
    (map-get? token-count account)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
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

;; Mint new NFT
;; can only be called from the Mint
(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) APE-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? Megapont-Ape-Club next-id new-owner)
        success
        (let
        ((current-balance (balance-of new-owner)))
          (begin
            (try! (stx-transfer? u23750000 tx-sender WALLET_1))
            (try! (stx-transfer? u22500000 tx-sender WALLET_2))
            (try! (stx-transfer?  u2500000 tx-sender WALLET_3))
            (try! (stx-transfer?  u1250000 tx-sender WALLET_4))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ 1 current-balance)
            )
            (ok true)))
        error (err (* error u10000)))))

;; update meta data

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)  
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint

(define-private (called-from-mint)
  (let ((the-mint
          (unwrap! (map-get? mint-address true)
                    false)))
    (is-eq contract-caller the-mint)))

;; can only be called once
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender)) 
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))