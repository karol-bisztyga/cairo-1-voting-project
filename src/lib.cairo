#[contract]
mod VotingContract {
  use starknet::get_caller_address;
  use starknet::contract_address::contract_address_to_felt252;

  struct Storage {
    yes_votes: felt252,
    no_votes: felt252,
    voters: LegacyMap::<felt252, bool>,
  }

  #[external]
  fn vote(vote: felt252) {
    assert(vote == 0 | vote == 1, 'vote can only be 0/1');
    let caller = contract_address_to_felt252(get_caller_address());
    assert(caller != 0, 'no caller address detected');
    let did_vote = voters::read(caller);
    if did_vote == true {
      return ();
    }
    if vote == 0 {
      no_votes::write(no_votes::read()+1);
    } else if vote == 1 {
      yes_votes::write(yes_votes::read()+1);
    }
    voters::write(caller, true);
  }

  #[view]
  fn get_votes() -> (felt252, felt252) {
    (no_votes::read(), yes_votes::read())
  }
}
