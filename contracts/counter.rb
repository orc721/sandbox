# encoding: utf-8

####################################################
# Counter Contract - Let's Count - 0,1,2,3

require "michelson"


type :Storage, Integer

init [],
def storage()
  0
end

entry [Integer],
def inc( by, storage )
  [[], storage + by]
end



################################
## Test, Test, Test

storage  = storage()
_, storage = inc( 2, storage )
_, storage = inc( 1, storage )
