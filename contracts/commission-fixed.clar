(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u40) tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5))
        (ok true)))
