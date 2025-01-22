#[test_only]
module aynrand::ticket_test {
    
    use std::debug;
    use std::string::utf8;
    use sui::test_scenario::{Self, Scenario};
    use aynrand::base_test as base;
    use aynrand::ticket::{Self, AdminCap};

    use aynrand::helper_test;

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
}
//#[allow(unused_field)]
//fun test_buy_ticket(){}
//#[allow(unused_field)]
//fun test_activate_ticket(){}

