New to (Secure) Ruby? See the [Red Paper](https://github.com/s6ruby/redpaper)!


# (Secure) Ruby to Liquidity w/ ReasonML Syntax / Michelson (Source-to-Source) Cross-Compiler Cheat Sheet / White Paper

**What's Michelson? What's Liquidity?**

The Liquidity language lets you programm (crypto) contracts with (higher-level type-safe functional) OCaml or ReasonML syntax (see <http://www.liquidity-lang.org>)
compiling to (low-level) Michelson stack machine bytecode (see <https://www.michelson-lang.com>).




## By Example


### Let's Count - 0, 1, 2, 3

[Ruby Version](#ruby) •
[Liquidity (w/ ReasonML) Version]()



#### Ruby

``` ruby
type :Storage, Integer

init [],
def storage()
  0
end

entry [Integer],
def inc( by, storage )
  [[], storage + by]
end
```

#### Liquidity (w/ ReasonML)

gets cross-compiled to:

``` reason
type storage = int;

let%init storage = () => {
  0;
};

let%entry inc = (by: int, storage) => {
  ([], storage + by);
};
```


#### Test, Test, Test

Note: For (local) testing you can run the "Yes, It's Just Ruby" version with the michelson testnet "simulator" library. See [`/michelson »` ](michelson). Example:

``` ruby
storage  = storage()
# => calling storage()...
# => returning:
# => 0
_, storage = inc( 2, storage )
# => calling inc( 2, 0 )...
# => returning:
# => [[], 2]
_, storage = inc( 1, storage )
# => calling inc( 1, 2 )...
# => returning:
# => [[], 3]
```


### Let's Vote

[Ruby Version](#ruby) •
[Liquidity (w/ ReasonML) Version]()


#### Ruby

``` ruby
type :Storage, Map‹String→Integer›

init [],
def storage()
  {"ocaml" => 0, "reason" => 0, "ruby" => 0}
end

entry [String],
def vote( choice, votes )
  amount = Current.amount
  if amount < 5.tz
    failwith( "Not enough money, at least 5tz to vote" )
  else
    match Map.find(choice, votes), {
      None: ->()  { failwith( "Bad vote" ) },
      Some: ->(x) { votes = Map.add(choice, x + 1, votes); [[], votes] }}
  end
end
```


gets cross-compiled to:

``` reason
type storage = map(string, int);

let%init storage = () => {
  Map([("ocaml", 0), ("reason", 0), ("ruby", 0)]);
};

let%entry vote = (choice: string, votes) => {
  let amount = Current.amount();
  if (amount < 5.00tz) {
    failwith("Not enough money, at least 5tz to vote");
  } else {
    switch (Map.find(choice, votes)) {
    | None    => failwith("Bad vote")
    | Some(x) =>
        let votes = Map.add(choice, x + 1, votes);
        ([], votes);
    };
  };
};
```

Note: For (local) testing you can run the "Yes, It's Just Ruby" version with the michelson testnet "simulator" library. Example:

``` ruby
storage  = storage()
#=> calling storage()...
#=> returning:
#=> {"ocaml"=>0, "reason"=>0, "ruby"=>0}
_, storage = vote( "ruby", storage )
#=> calling vote( "ruby", {"ocaml"=>0, "reason"=>0, "ruby"=>0} )...
#=> !! RuntimeError: failwith - Not enough money, at least 5tz to vote

Current.amount = 10.tz

_, storage = vote( "ruby", storage )
#=> calling vote( "ruby", {"ocaml"=>0, "reason"=>0, "ruby"=>0} )...
#=> returning:
#=> [[], {"ocaml"=>0, "reason"=>0, "ruby"=>1}]
_, storage = vote( "reason", storage )
#=> calling vote( "reason", {"ocaml"=>0, "reason"=>0, "ruby"=>1} )...
#=> returning:
#=> [[], {"ocaml"=>0, "reason"=>1, "ruby"=>1}]
_, storage = vote( "python", storage )
#=> calling vote( "python", {"ocaml"=>0, "reason"=>1, "ruby"=>1} )...
#=> !! RuntimeError: failwith - Bad vote
```


**Minimum Viable Token**

``` ruby
type :Account, {
  balance:      Nat,
  allowances:   Map‹Address→Nat› }

type :Storage, {
  accounts:     BigMap‹Address→Account›,
  version:      Nat,
  total_supply: Nat,
  decimals:     Nat,
  name:         String,
  symbol:       String,
  owner:        Address }

init [Address, Nat, Nat, String, String],
def storage( owner, total_supply, decimals, name, symbol )
  owner_account = Account.new( total_supply, {} )
  accounts      = Map.add( owner, owner_account, {} )
  Storage.new( accounts, 1.p, total_supply, decimals, name, symbol, owner )
end

sig [Address, BigMap‹Address→Account›],
def get_account(a, accounts)
  match Map.find(a, accounts), {
    None: ->()        { Account.new( 0.p, {} ) },  ## fix: allow (struct) init with keys too
    Some: ->(account) { account }}
end

sig [Address, Address, Nat],
def perform_transfer(from, dest, tokens, storage)
  accounts = storage.accounts
  account_sender = get_account( from, accounts )
  new_account_sender =
    match is_nat(account_sender.balance - tokens), {
     None: ->()  { failwith( "Not enough tokens for transfer", account_sender.balance ) },
     Some: ->(b) {
                    ## fix (w/o clone) was: account_sender.balance = b
                    account_sender_clone = account_sender.clone
                    account_sender_clone.balance = b
                    account_sender_clone
                 }}

  accounts = Map.add(from, new_account_sender, accounts)
  account_dest = get_account( dest, accounts )
  ## fix (w/o) clone was:  new_account_dest = account_dest.balance = account_dest.balance + tokens
  account_dest_clone = account_dest.clone
  account_dest_clone.balance = account_dest.balance + tokens
  new_account_dest = account_dest_clone
  accounts = Map.add(dest, new_account_dest, accounts)

  ## fix (w/o clone) was:  [[], storage.accounts = accounts]
  storage_clone = storage.clone
  storage_clone.accounts = accounts
  [[], storage_clone]
end

entry [Address, Nat],
def transfer( dest, tokens, storage )
  perform_transfer( Current.sender, dest, tokens, storage )
end

entry [Address, Nat],
def approve( spender, tokens, storage )
  account_sender = get_account( Current.sender, storage.accounts)

  ## fix (w/o clone) was:  account_sender = account_sender.allowances =
  account_sender = account_sender.clone
    account_sender.allowances =
      if tokens == 0.p
        Map.remove( spender, account_sender.allowances )
      else
        Map.add( spender, tokens, account_sender.allowances )
      end

  storage = storage.clone
    ## fix (w/o clone) was: storage = storage.accounts =
    storage.accounts = Map.add( Current.sender, account_sender, storage.accounts);

  [[], storage]
end

entry [Address, Address, Nat],
def transfer_from( from, dest, tokens, storage)
  account_from = get_account( from, storage.accounts )
  new_allowances_from =
    match Map.find( Current.sender, account_from.allowances ), {
      None: ->()        { failwith( "Not allowed to spend from", from ) },
      Some: ->(allowed) {
        match is_nat(allowed - tokens), {
          None: ->() { failwith( "Not enough allowance for transfer", allowed ) },
          Some: ->(allowed) {
            if allowed == 0.p
              Map.remove( Current.sender, account_from.allowances )
            else
              Map.add( Current.sender, allowed, account_from.allowances )
            end
          }
        }
      }
    }
  ## fix (w/o clone) was: account_from =
  account_from = account_from.clone
  account_from.allowances = new_allowances_from
  ## fix (w/o clone was: storage =
  storage = storage.clone
    storage.accounts = Map.add( from, account_from, storage.accounts )
  perform_transfer( from, dest, tokens, storage )
end

entry [Address, Nat],
def create_account( dest, tokens, storage )
  if Current.sender != storage.owner
    failwith( "Only owner can create accounts" )
  end
  perform_transfer( storage.owner, dest, tokens, storage )
end
```

gets cross-compiled to:

``` reason
type account = {
  balance: nat,
  allowances: map(address, nat),
};

type storage = {
  accounts: big_map(address, account),
  version: nat /* version of token standard */,
  totalSupply: nat,
  decimals: nat,
  name: string,
  symbol: string,
  owner: address,
};

let%init storage = (owner, totalSupply, decimals, name, symbol) => {
  let owner_account = {balance: totalSupply, allowances: Map};
  let accounts = Map.add(owner, owner_account, BigMap);
  {accounts, version: 1p, totalSupply, decimals, name, symbol, owner};
};

let get_account = ((a, accounts: big_map(address, account))) =>
  switch (Map.find(a, accounts)) {
  | None => {balance: 0p, allowances: Map}
  | Some(account) => account
  };

let perform_transfer = ((from, dest, tokens, storage)) => {
  let accounts = storage.accounts;
  let account_sender = get_account((from, accounts));
  let new_account_sender =
    switch (is_nat(account_sender.balance - tokens)) {
    | None =>
      failwith(("Not enough tokens for transfer", account_sender.balance))
    | Some(b) => account_sender.balance = b
    };
  let accounts = Map.add(from, new_account_sender, accounts);
  let account_dest = get_account((dest, accounts));
  let new_account_dest = account_dest.balance = account_dest.balance + tokens;
  let accounts = Map.add(dest, new_account_dest, accounts);
  ([], storage.accounts = accounts);
};

let%entry transfer = ((dest, tokens), storage) =>
  perform_transfer((Current.sender(), dest, tokens, storage));

let%entry approve = ((spender, tokens), storage) => {
  let account_sender = get_account((Current.sender(), storage.accounts));
  let account_sender =
    account_sender.allowances = (
      if (tokens == 0p) {
        Map.remove(spender, account_sender.allowances);
      } else {
        Map.add(spender, tokens, account_sender.allowances);
      }
    );
  let storage =
    storage.accounts =
      Map.add(Current.sender(), account_sender, storage.accounts);
  ([], storage);
};

let%entry transferFrom = ((from, dest, tokens), storage) => {
  let account_from = get_account((from, storage.accounts));
  let new_allowances_from =
    switch (Map.find(Current.sender(), account_from.allowances)) {
    | None => failwith(("Not allowed to spend from", from))
    | Some(allowed) =>
      switch (is_nat(allowed - tokens)) {
      | None => failwith(("Not enough allowance for transfer", allowed))
      | Some(allowed) =>
        if (allowed == 0p) {
          Map.remove(Current.sender(), account_from.allowances);
        } else {
          Map.add(Current.sender(), allowed, account_from.allowances);
        }
      }
    };
  let account_from = account_from.allowances = new_allowances_from;
  let storage =
    storage.accounts = Map.add(from, account_from, storage.accounts);
  perform_transfer((from, dest, tokens, storage));
}

let%entry createAccount = ((dest, tokens), storage) => {
  if (Current.sender() != storage.owner) {
    failwith("Only owner can create accounts");
  };
  perform_transfer((storage.owner, dest, tokens, storage));
};
```



## Bonus: (Secure) Ruby to SmartPy to SmartML / Michelson (Source-to-Source) Cross-Compiler Cheat Sheet

The SmartPy¹ library for programming contracts with Python
(see [Introducing SmartPy](https://medium.com/@SmartPy_io/introducing-smartpy-and-smartpy-io-d4013bee7d4e))
compiles to SmartML and onto Michelson bytecode.

¹: Upcoming / Planned for Summer 2019



**Let's Play Nim**

> Nim is a mathematical game of strategy in which two players take turns
> removing objects from distinct heaps.
> On each turn, a player must remove at least one object,
> and may remove any number of objects provided they all come from the same heap.
> The goal of the game is to avoid taking the last object.
>
> (Source: [Nim @ Wikipedia](https://en.wikipedia.org/wiki/Nim))


``` ruby
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
    @winner = 3 - @nextPlayer
  else
    @winner = @nextPlayer
end
```

Or using an alternative "meta" parameterized contract template / factory:

``` ruby
####################################
# Nim Game Contract Template
#
# Parameter Options:
# - bound          (default: nil)
# - winner_is_last (default: false)

sig [Integer],
def setup( size )
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
  if $DEFINED[:bound]
    assert k <= $PARA[:bound]
  end
  assert k <= @deck[cell]

  @deck[cell] -=  k
  @nextPlayer = 3 - @nextPlayer   ## toggles between 1|2
end

def claim
  assert @deck.sum == 0

  @claimed = true
  if $TRUE[:winner_is_last]
    @winner = 3 - @nextPlayer
  else
    @winner = @nextPlayer
  end
end
```

gets cross-compiled to:


``` python
import smartpy as sp

class NimGame(sp.Contract):
    def __init__(self, size, bound = None, winnerIsLast = False):
        self.bound        = bound
        self.winnerIsLast = winnerIsLast
        self.init(deck       = sp.range(1, size + 1),
                  size       = size,
                  nextPlayer = 1,
                  claimed    = False,
                  winner     = 0)

    @sp.message
    def remove(self, data, params):
        cell = params.cell
        k = params.k
        sp.check(0 <= cell)
        sp.check(cell < data.size)
        sp.check(1 <= k)
        if self.bound is not None:
            sp.check(k <= self.bound)
        sp.check(k <= data.deck[cell])
        sp.set(data.deck[cell], data.deck[cell] - k)
        sp.set(data.nextPlayer, 3 - data.nextPlayer)

    @sp.message
    def claim(self, data, params):
        sp.check(sp.sum(data.deck) == 0)
        sp.set(data.claimed, True)
        if self.winnerIsLast:
            sp.set(data.winner, 3 - data.nextPlayer)
        else:
            sp.set(data.winner, data.nextPlayer)
```


## Notes



## License

![](https://publicdomainworks.github.io/buttons/zero88x31.png)

The (secure) ruby cross-compiler scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Request for Comments (RFC)

Send your questions and comments to the ruby-talk mailing list. Thanks!
