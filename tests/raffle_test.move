#[test_only]
#[allow(unused_use)]
module aynrand::raffle_test {

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
            .when_time_passes(END_TIME + 1)
            .when_drawing_winner(admin);

            // Then
            //.then_exactly_one_winner()
            //.then_prize_distributed();

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
    use fun fw::when_drawing_winner as Scenario.when_drawing_winner;
    use fun fw::when_time_passes as Scenario.when_time_passes;

    // === Then functions ===
    use fun fw::then_ticket_exist as Scenario.then_ticket_exist;
    //use fun fw::then_exactly_one_winner as Scenario.then_exactly_one_winner;
    //use fun fw::then_prize_distributed as Scenario.then_prize_distributed;

}