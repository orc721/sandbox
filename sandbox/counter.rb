require_relative "michelson"



type :Storage, Integer

init [],
def storage()
  0
end

entry [Integer],
def inc( by, storage )
  [[], storage + by]
end


storage  = storage()
_, storage = inc( 2, storage )
_, storage = inc( 1, storage )
