# encoding: utf-8

#####################################
# Let's Vote

require "michelson"



type :Storage, Map‹String→Integer›

init [],
def storage()
  {"ocaml" => 0, "reason" => 0, "ruby" => 0}
end

entry [String],
def vote( choice, votes )
  amount = Current.amount
  if amount < 5.tz
    Current.failwith( "Not enough money, at least 5tz to vote" )
  else
    match Map.find(choice, votes), {
     None: ->()  { Current.failwith( "Bad vote" ) },
     Some: ->(x) { votes = Map.add(choice, x + 1, votes); [[], votes] }}
  end
end


storage  = storage()
#=> calling storage()...
#=> returning:
#=> {"ocaml"=>0, "reason"=>0, "ruby"=>0}
# _, storage = vote( "ruby", storage )
#=> calling vote( "ruby", {"ocaml"=>0, "reason"=>0, "ruby"=>0} )...
#=> RuntimeError: failwith - Not enough money, at least 5tz to vote

Current.amount = 10.tz

storage  = storage()
#=> calling storage()...
#=> returning:
#=> {"ocaml"=>0, "reason"=>0, "ruby"=>0}
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
#=> RuntimeError: failwith - Bad vote
