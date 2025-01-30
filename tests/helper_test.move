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
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::random::{Self, Random};


    // === Local Code errors ===
    const START_TIME: u64 = 1000;
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

    #[test_only]
    public fun given_minted_tickets(scenario: &mut Scenario, admin: address, amount: u64): &mut Scenario {
        scenario.next_tx(admin);
        {
            let admin_cap = scenario.take_from_sender<AdminCap>();
            let mut clock = test_scenario::take_shared<Clock>(scenario);

            let mut counter = test_scenario::take_from_sender<Counter>(scenario);
            let mut raffle = scenario.take_shared<Raffle>();
            let name = utf8(b"AYN");

            raffle::mint_tickets_to_raffle(
                &admin_cap, 
                &mut raffle, 
                amount,
                name,
                &mut counter,
                &clock,
                scenario.ctx()
            );

            clock::increment_for_testing(&mut clock, 1);

            scenario.return_to_sender(admin_cap);
            scenario.return_to_sender(counter);
            test_scenario::return_shared(clock);

            test_scenario::return_shared(raffle);
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

    #[test_only]
    public fun when_funding_buyers(scenario: &mut Scenario, buyers: vector<address>, amount: u64): &mut Scenario {
        let mut i = 0;
        let buyers_length = vector::length(&buyers);
        
        while (i < buyers_length) {
            let buyer = *vector::borrow(&buyers, i);
            
            scenario.next_tx(buyer);
            {
                let _coin = coin::mint_for_testing<SUI>(amount, scenario.ctx());
                transfer::public_transfer(_coin, buyer);
            };        

            i = i + 1;
        };
        scenario
    }

    #[test_only]
    public fun when_buyers_buy_tickets(scenario: &mut Scenario, buyers: vector<address>, amount: u64, to_commit: vector<vector<u8>>): &mut Scenario {
        let mut i = 0;
        while (i < amount) {

            let buyer = *vector::borrow(&buyers, i);
            test_scenario::next_tx(scenario, buyer);
            {
                let ticket_commit =  *vector::borrow(&to_commit, i);

                let mut raffle = test_scenario::take_shared<Raffle>(scenario);
                let payment = test_scenario::take_from_sender<Coin<SUI>>(scenario);
                let clock = test_scenario::take_shared<Clock>(scenario);
                
                // Increment clock
                // clock::increment_for_testing(&mut clock, START_TIME + 1);
                
                raffle::buy_ticket(&mut raffle, payment, utf8(ticket_commit), &clock, test_scenario::ctx(scenario));

                test_scenario::return_shared(clock);
                test_scenario::return_shared(raffle);
            };
            
            i = i + 1;
        };
        scenario
    }

    #[test_only]
    public fun when_time_passes(scenario: &mut Scenario, end_time: u64): &mut Scenario {
        scenario.next_tx(base::admin());
        {
            let mut clock = test_scenario::take_shared<Clock>(scenario);
            clock::set_for_testing(&mut clock, end_time);
            test_scenario::return_shared(clock);
        };
        scenario
    }

    #[test_only]
    public fun when_drawing_winner(scenario: &mut Scenario, admin: address): &mut Scenario {
        test_scenario::next_tx(scenario, admin);
        {
            let mut raffle = test_scenario::take_shared<Raffle>(scenario);
            let clock = test_scenario::take_shared<Clock>(scenario);
            

            // Create and use random object
            random::create_for_testing(scenario.ctx());

            let luck = test_scenario::take_shared<Random>(scenario);
            raffle::draw_winner(&mut raffle, &clock, &luck, test_scenario::ctx(scenario));
            
            test_scenario::return_shared(clock);
            test_scenario::return_shared(raffle);
            test_scenario::return_shared(luck);
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