#[test_only]
public fun when_drawing_winner(scenario: &mut Scenario, admin: address): &mut Scenario {
    test_scenario::next_tx(scenario, admin);
    {
        let raffle = test_scenario::take_shared<Raffle>(scenario);
        let clock = test_scenario::take_shared<Clock>(scenario);
        
        raffle::draw_winner(&mut raffle, &clock, test_scenario::ctx(scenario));
        
        test_scenario::return_shared(clock);
        test_scenario::return_shared(raffle);
    };
    scenario
}

fun it_should_complete_raffle_e2e() {
    let (admin, mut scenario) = fw::setup_test();
    let (ayn, guys) = base::generate_signers(base::default_amount());
    
    let commitments = base::generate_ten_commitments();

    scenario

        // Given
        .given_admin(admin)
        .given_clock( START_TIME - 1)
        .given_raffle(START_TIME, END_TIME, admin)

        .given_minted_tickets(admin, base::default_amount())

        // When
        .when_funding_buyers(guys, base::default_price())
        .when_buyers_buy_tickets(guys, base::default_amount(), commitments)

        // Then

    // Start Raffle


        

    scenario.end();
}

// === Unit Tests ===
#[test]
fun it_should_create_a_new_raffle_() {
    let (admin, mut scenario) = fw::setup_test();
    
    scenario
        .given_admin(admin)
        .given_raffle(START_TIME, END_TIME, admin);

    scenario.end();
}

/// Extending Scenario with framework functions

// === Given functions ===
use fun fw::given_admin as Scenario.given_admin;
use fun fw::given_clock as Scenario.given_clock;
use fun fw::given_raffle as Scenario.given_raffle;
use fun fw::given_minted_tickets as Scenario.given_minted_tickets;

// === When functions ===
use fun fw::when_minting as Scenario.when_minting;
use fun fw::when_burning as Scenario.when_burning;
use fun fw::when_funding_buyers as Scenario.when_funding_buyers;
use fun fw::when_buyers_buy_tickets as Scenario.when_buyers_buy_tickets;


