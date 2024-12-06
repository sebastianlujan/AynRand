#[test_only]
module aynrand::ticket_test {
    use sui::test_scenario::{Self as ts};
    // use aynrand::test_base::{Self as tb};
    
    use aynrand::ticket::{Self, Ticket, AdminCap };
    use std::{string::utf8};

    /// 1 MIST represent 10^-9 Sui
    /// const PRICE: u64 = 1_000_000_000;

    const ADMIN: address = @0xCAFE;
    const TEN: u64 = 10;

    #[test]
    fun test_mint_ticket() {
        let mut scenario = ts::begin(ADMIN);
        {   
            let admin_cap = ts::take_from_sender<AdminCap>(&scenario);
            let ctx = ts::ctx(&mut scenario);

            ticket::mint(&admin_cap, TEN, utf8(b"TEST"), ctx);

            // Test the first minted ticket
            let _ticket = ts::take_from_sender<Ticket>(&scenario);
            assert!(ticket::name(&_ticket) == &utf8(b"TEST"), 0);
            assert!(ticket::active(&_ticket) == &false, 1);
            
            ts::return_to_sender(&scenario, _ticket);
            ts::return_to_sender(&scenario, admin_cap);
        };

        ts::end(scenario);
    }
}