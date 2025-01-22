#[test_only]
#[allow(unused_use)]

module aynrand::helper_test {

    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, AdminCap};
    use aynrand::ticket_test;

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
            assert!(ticket::name(&ticket) == utf8(b"TEST"), 0);
            assert!(ticket::owner(&ticket) == admin, 1);
            assert!(ticket::is_active(&ticket) == true, 2);

            scenario.return_to_sender(admin_cap);
            ticket::burn(ticket, scenario.ctx());
        };
        scenario
    }
    
    #[test_only]
    public fun then_verify(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        { };
        scenario
    }


    #[test_only]
    public fun then_ticket_exist(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        { };
        scenario
    }

    #[test_only]
    public fun then_ticket_not_exist(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        { };
        scenario
    }
}