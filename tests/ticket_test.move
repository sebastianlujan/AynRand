#[test_only]
module aynrand::ticket_test {

    use sui::test_scenario::{Self, Scenario};
    use aynrand::helper_test as fw;

   
    /// We use BDD Gherking like testing semantics
    /// we choose BDD over TDD because it is cleaner and expressive
    /// https://www.browserstack.com/guide/tdd-vs-bdd-vs-atdd

    #[test]
    fun it_should_mint_new_ticket() {
        
        // Setup scenario
        let(admin, mut scenario) = fw::setup_test();

        scenario
            .given_admin(admin)
            .when_minting(admin)
            .then_ticket_exist(admin);
        
        scenario.end();
    }


    #[test]
    fun it_should_mint_multiple_tickets() {
        
        // Setup scenario
        let(admin, mut scenario) = fw::setup_test();
        
        scenario
            .given_admin(admin)
            .when_minting(admin)
            .when_minting(admin)
            .when_minting(admin)
            .then_ticket_exist(admin);

        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun it_should_mint_new_ticket_and_burn() {
        
        // Setup scenario
        let(admin, mut scenario) = fw::setup_test();

        scenario
            .given_admin(admin)
            .when_minting(admin)
            .when_burning(admin)
            .then_ticket_exist( admin);
        
        scenario.end();
    }

    /// Extending Scenario with framework functions
    /// https://move-book.com/reference/uses.html
    /// https://move-book.com/move-basics/struct-methods.html?highlight=alias#aliasing-an-external-modules-method
    
    use fun fw::given_admin as Scenario.given_admin;
    use fun fw::when_minting as Scenario.when_minting;
    use fun fw::when_burning as Scenario.when_burning;
    use fun fw::then_ticket_exist as Scenario.then_ticket_exist;
}