#[test_only]
#[allow(unused_use)]
module aynrand::raffle_test {
    use sui::test_scenario::{Self as ts, Scenario};
    use aynrand::base_test::{Self as tb};
    use aynrand::ticket_test;

    use aynrand::raffle::{Self, Raffle};
    use aynrand::ticket::{Self, AdminCap, Ticket};
    
    use std::{string::utf8};


    #[test]
    public fun test_buy_ticket() {
        let admin = tb::admin();
        let mut scenario = ts::begin(admin);

        ts::next_tx(&mut scenario, admin);
    
        let admin_cap = ticket::test_new_admin_cap(ts::ctx(&mut scenario));
        
        ticket::create_tickets(
            &admin_cap, 
            tb::default_name().to_string(), 
            tb::default_amount(), 
            ts::ctx(&mut scenario)
        );
        ticket::test_destroy_admin_cap(admin_cap);        
    
        ts::end(scenario);
    }
}