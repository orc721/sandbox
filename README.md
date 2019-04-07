New to (Secure) Ruby? See the [Red Paper](https://github.com/s6ruby/redpaper)!


# (Secure) Ruby to Liquidity w/ ReasonML Syntax / Michelson (Source-to-Source) Cross-Compiler Cheat Sheet / White Paper


The Liquidity Language for programming contracts with OCaml or ReasonML syntax (see <http://www.liquidity-lang.org>)
compiles to (low-level) Michelson stack machine bytecode (see <https://www.michelson-lang.com>).



## By Example


**Let's Count - 0, 1, 2, 3**

``` ruby
def setup
  @counter = 0
end

sig [Integer],
def inc( by )
  @counter += by
end
```

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

gets cross-compiled to:

``` reason
type storage = map(string, int);

let%init storage = () => {
  Map([("ocaml", 0), ("reason", 0), ("ruby", 0)]);
};

let%entry vote = (choice: string, votes) => {
  let amount = Current.amount();
  if (amount < 5.00tz) {
    Current.failwith("Not enough money, at least 5tz to vote");
  } else {
    switch (Map.find(choice, votes)) {
    | None => Current.failwith("Bad vote")
    | Some(x) =>
      let votes = Map.add(choice, x + 1, votes);
      ([], votes);
    };
  };
};
```



**Minimum Viable Token**

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
