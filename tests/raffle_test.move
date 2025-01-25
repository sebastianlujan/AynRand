#[test_only]
#[allow(unused_use)]
module aynrand::raffle_test;

use sui::test_scenario::{Self, Scenario};
use aynrand::base_test as base;
use aynrand::helper_test as fw;
use aynrand::raffle;
use aynrand::ticket;
use sui::clock;
use sui::coin;
use sui::sui::SUI;

const START_TIME: u64 = 1000;
const END_TIME: u64 = 2000;

// === Unit Tests ===

#[test]
fun it_should_create_a_new_raffle_() {

}

use fun fw::given_admin as Scenario.given_admin;
use fun fw::when_minting as Scenario.when_minting;
use fun fw::when_burning as Scenario.when_burning;
