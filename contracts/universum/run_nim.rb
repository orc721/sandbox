###################
# test nim contract  (with private local testnet / universum runtime)

require 'universum'

Account['0xaaaa']    ## Alice :-) and
Account['0xbbbb']    ## Bob


NimGame = Contract.load( './nim' )

## create contract e.g. NimGame(size = 5, bound = 2)
tx = Uni.send_transaction( from: '0xaaaa', data: [NimGame, 5, 2] )
nim = tx.receipt.contract
pp nim

# A first move e.g. execMessage("remove", cell = 2, k = 1)
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 2, 1] )
pp nim

# A second move e.g. execMessage("remove", cell = 2, k = 2)
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:remove, 2, 2] )
# !! An illegal move
# Try again e.g. execMessage("remove", cell = 2, k = 1)
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:remove, 2, 1] )

# Another illegal move e.g. execMessage("claim")
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:claim] )

# A third move e.g. execMessage("remove", cell = 1, k = 2)
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 1, 2] )

# More moves
#   execMessage("remove", cell = 0, k = 1)
#   execMessage("remove", cell = 3, k = 1)
#   execMessage("remove", cell = 3, k = 1)
#   execMessage("remove", cell = 3, k = 2)
#   execMessage("remove", cell = 4, k = 1)
#   execMessage("remove", cell = 4, k = 2)

Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 0, 1] )
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:remove, 3, 1] )
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 3, 1] )
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:remove, 3, 2] )
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 4, 1] )
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:remove, 4, 2] )
pp nim

# A failed attempt to claim e.g.execMessage("claim")
Uni.send_transaction( from: '0xbbbb', to: nim, data: [:claim] )

# A last removal e.g. execMessage("remove", cell = 4, k = 2)
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:remove, 4, 2] )
# And a final claim e.g. execMessage("claim")
Uni.send_transaction( from: '0xaaaa', to: nim, data: [:claim] )

pp nim
