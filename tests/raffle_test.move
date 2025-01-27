#[test_only]
#[allow(unused_use)]
module aynrand::raffle_test;

use sui::test_scenario::{Self, Scenario};
use aynrand::base_test as base;
use aynrand::helper_test as fw;
use aynrand::raffle;
use aynrand::ticket;
use sui::clock;

const START_TIME: u64 = 1000;
const END_TIME: u64 = 2000;
const TICKET_AMOUNT: u64 = 100;

// == End to End Test ==
#[test]
fun it_should_complete_raffle_e2e() {
    let (admin, mut scenario) = fw::setup_test();
    
    // Create Raffle
    scenario
        .given_admin(admin)
        .given_clock( START_TIME)
        .given_raffle(START_TIME, END_TIME, admin);
        
    // Mint Tickets to Raffle

    // Simulate ticket purchase

    // Advance Time and Draw Winner

    // Verify Winner
    scenario.end();


    // Generate 10 signers
    let (_, buyers) = base::generate_signers(10);


}

// === Unit Tests ===
#[test]
fun it_should_create_a_new_raffle_() {
    let (admin, mut scenario) = fw::setup_test();
    
    scenario
        .given_admin(admin)
        .when_creating_raffle(START_TIME, END_TIME, admin);

    scenario.end();
}

/// Extending Scenario with framework functions

// === Given functions ===
use fun fw::given_admin as Scenario.given_admin;
use fun fw::given_clock as Scenario.given_clock;
use fun fw::given_raffle as Scenario.given_raffle;

// === When functions ===
use fun fw::when_minting as Scenario.when_minting;
use fun fw::when_burning as Scenario.when_burning;
}

