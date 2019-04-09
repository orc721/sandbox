# encoding: utf-8

######################################
#  Minimum Viable Token

require "michelson"


type :Account, {
  balance:    Nat,
  allowances: Map‹Address→Nat› }


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




############################
# Test, Test, Test

storage = storage( "0x1111", 100_000_000, 2, "Shilling", "BTS")

get_account( "0x7777", storage.accounts )
get_account( "0x1111", storage.accounts )

_, storage = perform_transfer( "0x1111", "0xaaaa", 1000, storage )

# _, storage = transfer( "0xbbbb", 1000, storage )
#=> !! RuntimeError: failwith - Not enough tokens for transfer: 0

Current.sender = "0x1111"
_, storage = transfer( "0xbbbb", 1000, storage )

_, storage = approve( "0xcccc", 1000, storage )
_, storage = approve( "0xdddd", 1000, storage )

Current.sender = "0xcccc"
_, storage = transfer_from( "0x1111", "0x2222", 200, storage )
_, storage = transfer_from( "0x1111", "0x3333", 300, storage )

Current.sender = "0x1111"

_, storage = create_account( "0xeeee", 5000, storage )
_, storage = create_account( "0xffff", 6000, storage )
