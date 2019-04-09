# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_vote.rb


require 'helper'


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



class TestVote < MiniTest::Test

  def test_storage
     pp Storage
     assert_equal Storage, Map
  end

  def test_call
    storage  = storage()
    exp = {"ocaml" => 0, "reason" => 0, "ruby" => 0}
    assert_equal exp, storage

    Current.amount = 10.tz

    _, storage = vote( "ruby", storage )
    exp = {"ocaml" => 0, "reason" => 0, "ruby" => 1}
    assert_equal exp, storage

    _, storage = vote( "reason", storage )
    exp = {"ocaml" => 0, "reason" => 1, "ruby" => 1}
    assert_equal exp, storage
  end

end  # class TestCounter
