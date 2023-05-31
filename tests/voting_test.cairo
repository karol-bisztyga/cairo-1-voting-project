use array::ArrayTrait;
use result::ResultTrait;

fn invoke_vote(contract_address: felt252, pranked_address: felt252, value: felt252) {
    start_prank(pranked_address, contract_address);
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(value);
    invoke(contract_address, 'vote', @invoke_calldata).unwrap();
}

fn expect_votes_counters_values(contract_address: felt252, expected_no_votes: felt252, expected_yes_votes: felt252) {
    let result = call(contract_address, 'get_votes', @ArrayTrait::new()).unwrap();
    assert(*result.at(0_u32) == expected_no_votes, 'no votes value incorrect');
    assert(*result.at(1_u32) == expected_yes_votes, 'yes votes value incorrect');
}

#[test]
fn test_votes_counter_change() {
    let contract_address = deploy_contract('voting_contract', @ArrayTrait::new()).unwrap();

    expect_votes_counters_values(contract_address, 0, 0);
    invoke_vote(contract_address, 123, 1);
    expect_votes_counters_values(contract_address, 0, 1);
}

#[test]
fn test_voting_twice_from_the_same_account() {
    let contract_address = deploy_contract('voting_contract', @ArrayTrait::new()).unwrap();

    expect_votes_counters_values(contract_address, 0, 0);
    invoke_vote(contract_address, 123, 1);
    invoke_vote(contract_address, 123, 0);
    expect_votes_counters_values(contract_address, 0, 1);
}

#[test]
fn test_voting_multiple_times_from_different_accounts() {
    let contract_address = deploy_contract('voting_contract', @ArrayTrait::new()).unwrap();

    expect_votes_counters_values(contract_address, 0, 0);

    invoke_vote(contract_address, 101, 1);
    invoke_vote(contract_address, 102, 1);
    invoke_vote(contract_address, 103, 0);
    invoke_vote(contract_address, 104, 0);
    invoke_vote(contract_address, 105, 0);

    expect_votes_counters_values(contract_address, 3, 2);
}
