####################################################
# Counter Contract - Let's Count - 0,1,2,3

def setup
  @counter = 0
end

sig [Integer],
def inc( by )
  @counter += by
end
