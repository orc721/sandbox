# More (Secure) Ruby to Liquidity w/ ReasonML Syntax / Michelson (Source-to-Source) Examples


**Roll the Dice**

``` ruby
# to be done
```

gets cross-compiled to:

``` reason
type game = {
  number: nat,
  bet: tez,
  player: key_hash,
};

type storage = {
  game: option(game),
  oracle: address,
};

let%init storage = (oracle: address) => {game: None, oracle} /* Start a new game */;

let%entry play = ((number: nat, player: key_hash), storage) => {
  if (number > 100p) {
    failwith("number must be <= 100");
  };
  if (Current.amount() == 0tz) {
    failwith("bet cannot be 0tz");
  };
  if (2p * Current.amount() > Current.balance()) {
    failwith("I don't have enough money for this bet");
  };
  switch (storage.game) {
  | Some(g) => failwith(("Game already started with", g))
  | None =>
    let bet = Current.amount();
    let storage = storage.game = Some({number, bet, player});
    ([], storage);
  };
}

/* Receive a random number from the oracle and compute outcome of the
   game */

let%entry finish = (random_number: nat, storage) => {
  let random_number =
    switch (random_number / 101p) {
    | None => failwith()
    | Some((_, r)) => r
    };
  if (Current.sender() != storage.oracle) {
    failwith("Random numbers cannot be generated");
  };
  switch (storage.game) {
  | None => failwith("No game already started")
  | Some(game) =>
    let ops =
      if (random_number < game.number) {
        /* Lose */
        [];
      } else {
        /* Win */
        let gain =
          switch (game.bet * game.number / 100p) {
          | None => 0tz
          | Some((g, _)) => g
          };
        let reimbursed = game.bet + gain;
        [Account.transfer(~dest=game.player, ~amount=reimbursed)];
      };

    let storage = storage.game = None;
    (ops, storage);
  };
}

/* accept funds */;
let%entry fund = ((), storage) => ([], storage);
```



**Let's Vote (Again)**

``` ruby
# to be done
```

gets cross-compiled to:

``` reason
/* Smart contract for voting. Winners of vote split the contract
   balance at the end of the voting period. */

type storage = {
  voters: big_map(address, unit)   /*** Used to register voters */,
  votes: map(string, nat)          /*** Keep track of vote counts */,
  addresses: map(string, key_hash) /*** Addresses for payout */,
  deadline: timestamp              /*** Deadline after which vote closes */,
}

let%init storage = addresses => {
  /* Initialize vote counts to zero */
  votes:
    Map.fold(
      (((name, _kh), votes)) => Map.add(name, 0p, votes),
      addresses,
      Map,
    ),
  addresses,
  voters: BigMap /* No voters */,
  deadline: Current.time() + 3600 * 24 /* 1 day from now */,
}

/** Entry point for voting.
    @param choice A string corresponding to the candidate */

let%entry vote = (choice, storage) => {
  /* Only allowed while voting period is ongoing */
  if (Current.time() > storage.deadline) {
    failwith("Voting closed");
  } /* Voter must send at least 5tz to vote */;
  if (Current.amount() < 5.00tz) {
    failwith("Not enough money, at least 5tz to vote");
  } /* Voter cannot vote twice */;
  if (Map.mem(Current.sender(), storage.voters)) {
    failwith(("Has already voted", Current.sender()));
  };
  let votes = storage.votes;
  switch (Map.find(choice, votes)) {
  | None =>
    /* Vote must be for an existing candidate */
    failwith(("Bad vote", choice))
  | Some(x) =>
    /* Increase vote count for candidate */
    let storage = storage.votes = Map.add(choice, x + 1p, votes) /* Register voter */;
    let storage =
      storage.voters = Map.add(Current.sender(), (), storage.voters) /* Return updated storage */;
    ([], storage);
  };
}

/* Auxiliary function : returns the list of candidates with the
   maximum number of votes (there can be more than one in case of
   draw). */;

let find_winners = votes => {
  let (winners, _max) =
    Map.fold(
      (((name, nb), (winners, max))) =>
        if (nb == max) {
          ([name, ...winners], max);
        } else if (nb > max) {
          ([name], nb);
        } else {
          (winners, max);
        },
      votes,
      ([], 0p),
    );
  winners;
};

/** Entry point for paying winning candidates. */

let%entry payout = ((), storage) => {
  /* Only allowed once voting period is over */
  if (Current.time() <= storage.deadline) {
    failwith("Voting ongoing");
  } /* Indentify winners of vote */;
  let winners = find_winners(storage.votes) /* Balance of contract is split equally between winners */;
  let amount =
    switch (Current.balance() / List.length(winners)) {
    | None => failwith("No winners")
    | Some((v, _rem)) => v
    } /* Generate transfer operations */;
  let operations =
    List.map(
      name => {
        let dest =
          switch (Map.find(name, storage.addresses)) {
          | None => failwith() /* This cannot happen */
          | Some(d) => d
          };
        Account.transfer(~amount, ~dest);
      },
      winners,
    ) /* Return list of operations. Storage is unchanged */;
  (operations, storage);
};
```
