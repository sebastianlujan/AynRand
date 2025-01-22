#[test_only]
module aynrand::ticket_test {
    
    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, AdminCap};

    #[test]
    fun it_should_mint_new_ticket() {
        
        // Setup scenario 
        let admin = base::admin();
        let mut scenario = test_scenario::begin(admin);

        // gherking like testing semantics
        scenario
            .given_admin_capability(admin)
            .when_admin_mints_tickets(admin)
            .then_ticket_should_not_exist(admin);

        scenario.end();
    }

    // Helper functions

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
//#[allow(unused_field)]
//fun test_buy_ticket(){}
//#[allow(unused_field)]
//fun test_activate_ticket(){}

