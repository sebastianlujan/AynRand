#[test_only]
module aynrand::raffle_test;

use aynrand::base_test as tb;
use aynrand::raffle;
use aynrand::ticket;
use sui::clock;
use sui::test_scenario as ts;
use sui::coin;
use sui::sui::SUI;

const START_TIME: u64 = 1000;
const END_TIME: u64 = 2000;

/*
#[test]
fun test_raffle_flow() {
    let admin = tb::admin();
    let buyer1 = @0xBABE;

    let mut scenario_val = ts::begin(admin);
    let scenario = &mut scenario_val;

    ts::next_tx(scenario, admin);
    {
        let mut mock_clock = clock::create_for_testing(ts::ctx(scenario));
        clock::set_for_testing(&mut mock_clock, 0);

        let mut raffle_test = raffle::create_with_time_for_testing(
            START_TIME,
            END_TIME,
            ts::ctx(scenario),
        );

        let admin_cap = ticket::test_new_admin_cap(ts::ctx(scenario));

        raffle::mint_tickets_to_raffle(
            &admin_cap,
            &mut raffle_test,
            tb::default_amount(),
            tb::default_name().to_string(),
            &mock_clock,
            ts::ctx(scenario),
        );

        // Transfer objects to shared storage
        clock::share_for_testing(mock_clock);
        ticket::test_destroy_admin_cap(admin_cap);
    };

    // Buyer 1 purchases ticket
    ts::next_tx(scenario, buyer1);
    {
        let mut raffle = ts::take_shared<raffle::Raffle>(scenario);
        let clock = ts::take_shared<clock::Clock>(scenario);
        let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(scenario));
        
        raffle::buy_ticket(
            &mut raffle,
            payment,
            &clock,
            ts::ctx(scenario),
        );
        
        ts::return_shared(raffle);
        ts::return_shared(clock);
    };

    // Clean up shared objects
    ts::next_tx(scenario, admin);
    {
        let mut raffle_test = ts::take_shared<raffle::Raffle>(scenario);
        let mut clock = ts::take_shared<clock::Clock>(scenario);
        
        // First destroy the raffle
        raffle::test_destroy_raffle(raffle_test);
        clock::destroy_for_testing(clock);
    };
    
    ts::end(scenario_val);
}
*/