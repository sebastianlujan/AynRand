#[test_only]
module aynrand::ticket_test {
    
    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, Ticket, AdminCap};

    #[test]

    fun test_mint_ticket_flow() {

        let admin = base::admin();
        let alice = base::user();

        let mut scenario = test_scenario::begin(admin);

        scenario.initialize_admin_cap_test(admin);

        initialize_admin_cap_test(&mut scenario, admin);

        scenario.next_tx(admin);
        {
            // Create AdminCap role
            //let admin_cap = ticket::test_new_admin_cap(ts::ctx(&mut scenario));

            let admin_cap = scenario.take_shared<AdminCap>();

            let ticket = ticket::mint(
                &admin_cap, 
                utf8(b"TEST"),
                base::default_amount(),
                test_scenario::ctx(&mut scenario)
            );

            ticket::test_burn_ticket(ticket, scenario.ctx());
            ticket::test_destroy_admin_cap(admin_cap);
        };
        
        scenario.end();
    }

    // Helper functions

    //extending Scenario with initialize_admin_cap_test
    use fun initialize_admin_cap_test as Scenario.initialize_admin_cap_test;

    fun initialize_admin_cap_test(scenario: &mut Scenario, admin: address) {
        //ticket::test_new_admin_cap(ctx);
        scenario.next_tx(admin);
        {
            ticket::test_new_admin_cap(scenario.ctx());
        };

        scenario.next_tx(admin);
        {
            let admin_cap = scenario.take_from_sender<AdminCap>();
            admin_cap.test_mint_ticket(scenario.ctx());
        }
    }
}
//#[allow(unused_field)]
//fun test_buy_ticket(){}
//#[allow(unused_field)]
//fun test_activate_ticket(){}

