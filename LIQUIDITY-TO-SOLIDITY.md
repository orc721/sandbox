# Liquidity <=> Solidity Cheat Sheet


## By Example

**Let's Count - 0, 1, 2, 3**   - Solidity Version

``` ruby
def setup
  @counter = 0
end

sig [Integer],
def inc( by )
  @counter += by
end
```


**Let's Vote**

``` ruby
def setup
  @votes = Mapping.of( String => Integer )
  @votes[ "ocaml"  ] = 0
  @votes[ "reason" ] = 0
  @votes[ "ruby"   ] = 0
end

sig [String],
def vote( choice )
  assert msg.value >= 5.tz, "Not enough money, at least 5tz to vote"
  assert @votes.has_key?( choice ), "Bad vote"

  @votes[choice] += 1
end
```

