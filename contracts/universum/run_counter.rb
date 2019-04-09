###################
# test counter contract  (with private local testnet / universum runtime)

require 'universum'

Account['0xaaaa']    ## Alice :-) and
Account['0xbbbb']    ## Bob


Counter = Contract.load( './counter' )

## create contract
tx = Uni.send_transaction( from: '0xaaaa', data: Counter )
counter = tx.receipt.contract
pp counter

Uni.send_transaction( from: '0xaaaa', to: counter, data: [:inc, 1] )
Uni.send_transaction( from: '0xaaaa', to: counter, data: [:inc, 2] )
pp counter

Uni.send_transaction( from: '0xbbbb', to: counter, data: [:inc, 4] )
pp counter
