# Notes

## More Liquidity / Michelson Contract Languages

### SmartPy

SmartPy - run on Python with a Python-Library; cross-compiles (?) to SmartML (OCaml/Liqudity(?))

- <https://medium.com/@SmartPy_io/introducing-smartpy-and-smartpy-io-d4013bee7d4e>
- <https://smartpy.io>
- <https://twitter.com/SmartPy_io>

Example:

``` python
import smartpy as sp
class StoreValue(sp.Contract):
    def __init__(self, value):
        self.init(storedValue = value)
    @sp.message
    def replace(self, data, params):
        sp.set(data.storedValue, params.value)
    @sp.message
    def double(self, data, params):
        sp.set(data.storedValue, data.storedValue * 2)
    @sp.message
    def divide(self, data, params):
        sp.check(params.divisor != 0)
        sp.set(data.storedValue, data.storedValue / params.divisor)
```

or

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


###  LIGO

Pascal-like contract language

- <https://medium.com/tezos/introducing-ligo-a-new-smart-contract-language-for-tezos-233fa17f21c7>


Example:

```
type state =
  record
    goal     : nat;
    deadline : timestamp;
    backers  : map (address, nat);
    funded   : bool
  end
entrypoint contribute (storage store : state;
                   const sender  : address;
                   const amount  : mutez)
  : storage * list (operation) is
  var operations : list (operation) := []
  begin
    if now > store.deadline then
      fail "Deadline passed"
    else
      if store.backers.[sender] = None then
        store :=
          copy store with
            record
              backers = map_add store.backers (sender, amount)
            end
      else null
  end with (store, operations)
```
