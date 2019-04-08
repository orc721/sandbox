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


**Let's Vote**  - Solidity Version

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


**Minimum Viable Token** - Solidity Version


``` ruby
struct :Account,
  balance:    Money(0),
  allowances: Mapping.of( Address => Money )

sig [Address, Money, Integer, String, String],
def setup( owner, total_supply, decimals, name, symbol )
  @accounts = Mapping.of( Address => Account )
  @accounts[ owner ].total_supply = total_supply

  @version      = 1
  @total_supply = total_supply
  @decimals     = decimals
  @name         = name
  @symbol       = symbol
  @owner        = owner
end  

sig [Address, Money],
def transfer( dest, tokens )
 perform_transfer( msg.sender, dest, tokens )
end

sig [Address, Money],
def approve( spender, tokens )
  account_sender = @accounts[ msg.sender ]
  if tokens == 0
    account_sender.allowances[ spender ].delete
  else
    account_sender.allowances[ spender ] = tokens
  end
end  

sig [Address, Address, Money],
def transfer_from( from, dest, tokens )
  account_from = @accounts[ from ]

  assert account_from.allowances.has_key?( msg.sender ), "Not allowed to spend from: #{from}"

  allowed     = account_from.allowances[ msg.sender ]
  new_allowed = allowed - tokens
  assert new_allowed > 0, "Not enough allowance for transfer: #{allowed}"

  if new_allowed == 0
    account_from.allowances[ msg.sender ].delete
  else
    account_from.allowances[ msg.sender ] = new_allowed
  end

  perform_transfer( from, dest, tokens )
end

sig [Address, Money],
def create_account( dest, tokens )
  assert msg.sender == @owner, "Only owner can create accounts"
  perform_transfer( @owner, dest, tokens )
end

private

sig [Address, Address, Money],
def perform_transfer( from, dest, tokens )
  account_sender = @accounts[ from ]
  assert account_sender.balance - tokens > 0, "Not enough tokens for transfer: #{account_sender.balance}"  

  account_sender.balance -= token
  account_dest = @accounts[ dest ]
  account_dest.balance   += token
end
```

**Roll the Dice**  - Solidity Version

``` ruby
struct :Game,
  number:  0,
  bet:     Money(0),
  player:  Address(0)

sig [Address],
def setup( oracle )
  @oracle = oracle
  @game   = Game(0)
end

sig [Integer, Address],
def play(number, player)
  assert number <= 100, "number must be <= 100"
  assert msg.value > 0 "bet cannot be 0tz"

  assert 2 * msg.value <= this.balance, "I don't have enough money for this bet"
  assert @game != Game(0), "Game already started with: #{@game}"

  @game.number = number
  @game.bet    = msg.value
  @game.player = player
end

# Receive a random number from the oracle and compute outcome of the
#   game

sig [Integer],
def finish(random_number)
  random_number = random_nuber % 101

  assert msg.sender == @oracle_id, "Random numbers cannot be generated"
  assert @game == Game(0), "No game already started"

  if random_number < @game.number
    ## Lose
    ## - Do nothing
  else
    ## Win
    gain       = @game.bet * @game.number / 100
    reimbursed = @game.bet + gain
    @game.player.transfer( reimbursed )

    @game = Game(0)
  end
end

# accept funds
def fund(); end
```

**Let's Vote (Again)** - Solidity Version


``` ruby
sig [Array‹Address›],
def setup( addresses )

  @voters    = Mapping‹Address→Unit›.new
  @votes     = Mapping‹Address→Integer›.new
  @addresses = addresses
  @deadline  = block.timestamp + 1.day

  addresses.each do |address|
    @votes[address] = 0
  end
end

# Entry point for voting.
#   @param choice An address corresponding to the candidate

sig [Address],
def vote( choice )
  assert block.timestamp <= @deadline, "Voting closed"
  assert msg.value >= 5.tz, "Not enough money, at least 5tz to vote"
  assert !@voters.has_key?( msg.sender ), "Has already voted: #{msg.sender}"

  # Vote must be for an existing candidate
  assert @votes.has_key?( choice ),  "Bad vote: #{choice}"
  # Increase vote count for candidate
  @votes[choice] += 1
  # Register voter
  @voter[msg.sender]
end

# Auxiliary function : returns the list of candidates with the
#   maximum number of votes (there can be more than one in case of
#   draw).
def find_winners( votes )
  winners = Array‹Address›.new
  max     = 0
  votes.each do |addr,num|
     if num == max
       winners.push( addr )
     elsif num > max
       max = num
       winners.clear
       winners.push( addr )
     else
       # do nothing
     end
  end
  winners
end

# Entry point for paying winning candidates.
def payout
  # Only allowed once voting period is over
  assert block.timestamp > deadline, "Voting ongoing"
  # Indentify winners of vote
  winners = find_winners( @votes )
  # Balance of contract is split equally between winners
  amount = this.balance / winner.length

  winners.each do |winner|
    winner.transfer( amount )
  end
end
```









