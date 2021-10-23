(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u40) tx-sender 'ST7WNDQ5CDEJ694WHSWT3HPNNXXFVD36KNZFEQJ0))
        (ok true)))
