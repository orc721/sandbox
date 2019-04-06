####################################
# Nim Game Contract

sig [Integer, Option(Integer), Bool],
def setup( size, bound=nil, winner_is_last=false)
  @bound          = bound
  @winner_is_last = winner_is_last

  @deck           = Array( 1...size+1 )  ## e.g. [1,2,3,4,...]
  @size           = size
  @next_player    = 1
  @claimed        = false
  @winner         = 0
end

# cell - representing a cell from an array
# k    - a quantity to remove from this cell
sig [Integer, Integer],
def remove( cell, k )
  assert 0 <= cell
  assert cell < @size
  assert 1 <= k
  assert k <= @bound   if @bound
  assert k <= @deck[cell]

  @deck[cell] -=  k
  @nextPlayer = 3 - @nextPlayer   ## toggles between 1|2
end

def claim
  assert @deck.sum == 0

  @claimed = true
  if @winner_is_last
    @data.winner = 3 - @nextPlayer
  else
    @data.winner = @nextPlayer
end
