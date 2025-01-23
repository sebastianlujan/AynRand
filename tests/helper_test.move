#[test_only]
#[allow(unused_use)]

module aynrand::helper_test {

    use std::debug;
    use std::string::utf8;
    use sui::transfer;
    use std::option::{Self, Option};
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, AdminCap, Ticket};
    use aynrand::ticket_test;

    // === Local Code errors ===
    const TICKET_EXISTANCE_MISMATCH: u64 = 0;
    const TICKET_NAME_MISMATCH: u64 = 1;
    const TICKET_OWNER_MISMATCH: u64 = 2;
    const TICKET_ACTIVE_MISMATCH: u64 = 3;    

    const MOCK_RAFFLE_CONTRACT: address = @0x0;


      #[test_only]
    public fun given_admin(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            ticket::test_new_admin_cap(scenario.ctx());
        };
        scenario
    }

    #[test_only]
    public fun when_minting(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            let admin_cap = scenario.take_from_sender<AdminCap>();
            let ticket = ticket::mint(
                &admin_cap, 
                utf8(b"TEST"),
                base::default_amount(),
                scenario.ctx()
            );

            //how to test if the ticket is minted?
            assert!(ticket::name(&ticket) == utf8(b"TEST"), TICKET_NAME_MISMATCH);
            assert!(ticket::owner(&ticket) == admin, TICKET_OWNER_MISMATCH);
            assert!(*ticket::is_active(&ticket), TICKET_ACTIVE_MISMATCH);

            scenario.return_to_sender(admin_cap);
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
    public fun then_ticket_exist(should_exist: bool, scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            // Verify ticket exists in owner's inventory
            let ticket = scenario.take_from_sender<Ticket>();
            //assert!(!scenario.has_most_recent_for_sender<Ticket>(), TICKET_EXISTANCE_MISMATCH);
            test_scenario::return_to_sender(scenario, ticket);
        };
        scenario
    }
}