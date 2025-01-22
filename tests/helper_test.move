#[test_only]
#[allow(unused_use)]
module aynrand::helper_test {

    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, AdminCap};

    //extending Scenario with initialize_admin_cap_test
    use fun given_admin_capability as Scenario.given_admin_capability;
    use fun when_admin_mints_tickets as Scenario.when_admin_mints_tickets;
    use fun then_ticket_should_not_exist as Scenario.then_ticket_should_not_exist;

    #[test_only]
    fun given_admin_capability(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            ticket::test_new_admin_cap(scenario.ctx());
        };
        scenario
    }

    #[test_only]
    fun when_admin_mints_tickets(scenario: &mut Scenario, admin: address): &mut Scenario {

        scenario.next_tx(admin);
        {            
            let admin_cap = scenario.take_from_sender<AdminCap>();
            let ticket = ticket::mint(
                &admin_cap, 
                utf8(b"TEST"),
                base::default_amount(),
                scenario.ctx()
            );

            //test_scenario::return_shared<Ticket>(ticket);
            scenario.return_to_sender(admin_cap);
            ticket::test_burn_ticket(ticket, scenario.ctx())
        };
        scenario
    }
    
    #[test_only]
    fun then_ticket_should_not_exist(scenario: &mut Scenario, admin: address): &mut Scenario {
        scenario.next_tx(admin);
        {
            
        };
        scenario
    }
}