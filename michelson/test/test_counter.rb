# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_counter.rb


require 'helper'


type :Storage, Integer

init [],
def storage()
  0
end

entry [Integer],
def inc( by, storage )
  [[], storage + by]
end


class TestCounter < MiniTest::Test

  def test_storage
     pp Storage
     assert_equal Storage, Integer
  end

  def test_call
    storage  = storage()
    assert_equal 0, storage

    _, storage = inc( 2, storage )
    assert_equal 2, storage

    _, storage = inc( 1, storage )
    assert_equal 3, storage
  end

end  # class TestCounter
