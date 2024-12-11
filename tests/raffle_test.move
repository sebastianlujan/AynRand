#[test_only]
module aynrand::raffle_test {
    use sui::test_scenario::{Self as ts};
    use aynrand::base_test::{Self as tb};
    use aynrand::raffle;
    use aynrand::ticket;
    use sui::clock;

    const START_TIME: u64 = 1000;
    const END_TIME: u64 = 2000;

    #[test]
    fun test_raffle_flow() {
        let admin = tb::admin();
        let mut scenario = ts::begin(admin);
        ts::next_tx(&mut scenario, admin);

        let mut mock_clock = clock::create_for_testing(ts::ctx(&mut scenario));
        clock::set_for_testing(&mut mock_clock, 0);

        let mut raffle = raffle::create_with_time_for_testing(
            START_TIME,
            END_TIME,
            ts::ctx(&mut scenario)
        );
        
        let admin_cap = ticket::test_new_admin_cap(ts::ctx(&mut scenario));

        raffle::mint_tickets_to_raffle(
            &admin_cap,
            &mut raffle,
            tb::default_amount(),
            tb::default_name().to_string(),
            &mock_clock,
            ts::ctx(&mut scenario)
        );

        clock::destroy_for_testing(mock_clock);
        ticket::test_destroy_admin_cap(admin_cap);
        raffle::test_destroy_raffle(raffle);
        
        ts::end(scenario);
    }
}