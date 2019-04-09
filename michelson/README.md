
# Michelson - test simulator / runtime for type-safe 'n' functional (crypto) contracts

michelson gem / library - test simulator / runtime for type-safe 'n' functional (crypto) contracts

* home  :: [github.com/s6ruby/ruby-to-michelson](https://github.com/s6ruby/ruby-to-michelson)
* bugs  :: [github.com/s6ruby/ruby-to-michelson/issues](https://github.com/s6ruby/ruby-to-michelson/issues)
* gem   :: [rubygems.org/gems/michelson](https://rubygems.org/gems/michelson)
* rdoc  :: [rubydoc.info/gems/michelson](http://rubydoc.info/gems/michelson)



## Usage

**What's Michelson? What's Liquidity?**

The [Liquidity language](http://www.liquidity-lang.org) lets you programm (crypto) contracts with (higher-level type-safe functional) OCaml or ReasonML syntax
compiling to (lower-level) [Michelson stack machine bytecode](https://www.michelson-lang.com).


Using the michelson test simulator / runtime for type-safe 'n' functional (crypto) contracts you can now use a "Yes, It's Just Ruby" syntax.


### By Example

**Let's Count - 0, 1, 2, 3**

"Classic" Style

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

"Modern" Style with Language Syntax Pragmas

``` ruby
type Storage = Integer

init [],
def storage()
  0
end

entry [Integer],
def inc( by, storage )
  [[], storage + by]
end
```


And for (local) testing you can run the "Yes, It's Just Ruby" version with the michelson testnet "simulator" library. Try:

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


**Let's Vote**

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

"Modern" Style with Language Syntax Pragmas

``` ruby
type Storage = Map‹String→Integer›

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
      | None    => { failwith( "Bad vote" ) },
      | Some(x) => { votes = Map.add(choice, x + 1, votes); [[], votes] }}
  end
end
```

And again for (local) testing you can run the "Yes, It's Just Ruby" version with the michelson testnet "simulator" library. Try:

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

And so on and so forth.


## License

![](https://publicdomainworks.github.io/buttons/zero88x31.png)

The `michelson` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?

Send them along to the [wwwmake forum](http://groups.google.com/group/wwwmake).
Thanks!
