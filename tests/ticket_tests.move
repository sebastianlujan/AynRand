#[test_only]
#[allow(unused_use)]
module aynrand::ticket_test {
    use aynrand::base_test::{Self as tb};
    use sui::test_scenario::{Self as ts};
    
    use aynrand::ticket::{Self, Ticket, AdminCap };
    use std::{string::utf8};
    use std::debug;

    #[test]
    fun test_mint_ticket_flow() {
        let admin = tb::admin();
        let mut scenario = ts::begin(admin);

        
            let scenario_mut= &mut scenario;
            ts::next_tx(scenario_mut, admin);

            // Create AdminCap role
            let admin_cap = ticket::test_new_admin_cap(ts::ctx(&mut scenario));
            
            //ticket::mint(&admin_cap, 100, utf8(b"TEST"), ts::ctx(&mut scenario));
            ticket::create_tickets(
                &admin_cap, 
                tb::default_name().to_string(), 
                tb::default_amount(), 
                ts::ctx(&mut scenario)
            );

            //let ticket = ts::take_from_sender<Ticket>(&scenario);
           
            //ticket::test_destroy_ticket(ticket);
            //assert!(ticket::name(&ticket) == &utf8(b"TEST"), 0);
            //assert!(ticket::active(&ticket) == &false, 1);

            // Return objects
            //ts::return_to_sender(&scenario, ticket);
            //ticket::test_destroy_ticket(ticket);
            ticket::test_destroy_admin_cap(admin_cap);        
        

        ts::end(scenario);
    }

    //#[allow(unused_field)]
    //fun test_buy_ticket(){}
    //#[allow(unused_field)]
    //fun test_activate_ticket(){}
}