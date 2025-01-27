#[test_only]
#[allow(unused_use)]

module aynrand::helper_test {

    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    
    use aynrand::ticket::{Self, AdminCap, Ticket, Counter};
    use aynrand::raffle::{Self, Raffle};
    use aynrand::ticket_test;

    use sui::clock::{Self, Clock};


    // === Local Code errors ===
    const TICKET_NAME_MISMATCH: u64 = 1;
    const TICKET_OWNER_MISMATCH: u64 = 2;
    const TICKET_ACTIVE_MISMATCH: u64 = 3;    
    const TICKET_NUMBER_MISMATCH: u64 = 4;

    #[test_only]
    public fun setup_test(): (address, Scenario) {
        let admin = base::admin();
        let mut scenario = test_scenario::begin(admin);
        (admin, scenario)
    }

    // === Given functions === 
    #[test_only]
    public fun given_admin(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            ticket::test_new_admin_cap(scenario.ctx());
            ticket::test_new_counter(scenario.ctx());
        };
        scenario
    }

    #[test_only]
    public fun given_clock(scenario: &mut Scenario, start_time: u64): &mut Scenario {
        scenario.next_tx(base::admin());
        {
            let mut _clock = clock::create_for_testing(scenario.ctx());
            clock::set_for_testing(&mut _clock, start_time);
            clock::share_for_testing(_clock);
        };
        scenario
    }

    #[test_only]
    public fun given_raffle(scenario: &mut Scenario, start_time: u64, end_time: u64, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {             
            let admin_cap = scenario.take_from_sender<AdminCap>();
            let raffle = raffle::create(&admin_cap, start_time, end_time, scenario.ctx());
            scenario.return_to_sender(admin_cap);
            raffle::test_share_raffle(raffle);
        };
        scenario
    }


    // === When functions ===
    #[test_only]
    public fun when_minting(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            let admin_cap = scenario.take_from_sender<AdminCap>();
            let mut counter = test_scenario::take_from_sender<Counter>(scenario);
            
            let mut ticket = ticket::mint(
                &admin_cap, 
                &mut counter,
                utf8(b"TEST"),
                0,
                scenario.ctx()
            );

            ticket::increment(&mut ticket, &mut counter);

            //how to test if the ticket is minted?
            assert!(ticket::counter(&ticket) == 1, 1);  // Validate counter increment
            assert!(ticket::name(&ticket) == utf8(b"TEST"), TICKET_NAME_MISMATCH);
            assert!(ticket::owner(&ticket) == admin, TICKET_OWNER_MISMATCH);
            assert!(*ticket::is_active(&ticket), TICKET_ACTIVE_MISMATCH);
            assert!(ticket::counter(&ticket) != ticket::last_counter(&counter), TICKET_NUMBER_MISMATCH);

            scenario.return_to_sender(admin_cap);
            scenario.return_to_sender(counter);
            ticket::transfer(ticket, admin);
        };
        scenario
    }

    #[test_only]
    public fun when_burning(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            let ticket = scenario.take_from_sender<Ticket>();
            ticket::burn(ticket, scenario.ctx());
        };
        scenario
    }

    // === Then functions ===
    #[test_only]
    public fun then_ticket_exist(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            let ticket = scenario.take_from_sender<Ticket>();
            test_scenario::return_to_sender(scenario, ticket);
        };
        scenario
    }

    #[test_only]
    public fun clean(scenario: &mut Scenario) {

        assert!(test_scenario::has_most_recent_shared<Clock>(), 0);
        let clock = test_scenario::take_shared<Clock>(scenario);
        clock::destroy_for_testing(clock);

        // Clean up AdminCap if exists
        assert!(test_scenario::has_most_recent_for_sender<AdminCap>(scenario), 0);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
        ticket::test_destroy_admin_cap(admin_cap);


        // Clean up Counter if exists
        assert!(test_scenario::has_most_recent_for_sender<Counter>(scenario), 0);
        let counter = test_scenario::take_from_sender<Counter>(scenario);
        ticket::test_destroy_counter(counter);

        // Clean up Raffle if exists
        assert!(test_scenario::has_most_recent_shared<Raffle>(), 0);
        let raffle = test_scenario::take_shared<Raffle>(scenario);
        raffle::test_destroy_raffle(raffle);
    }
}