#[test_only]
module aynrand::ticket_test {
    use sui::test_scenario::{Self as ts};
    // use aynrand::test_base::{Self as tb};
    
    use aynrand::ticket::{Self, Ticket, AdminCap };
    use std::{string::utf8};

    /// 1 MIST represent 10^-9 Sui
    const PRICE: u64 = 1_000_000_000;
    const ADMIN: address = @0xCAFE;
    const TEN: u64 = 10;

    #[test]
    fun test_mint_ticket() {

        let mut scenario = ts::begin(ADMIN);
        {
            let admin_cap = ts::take_from_sender<AdminCap>(&scenario);
            
            let ctx = ts::ctx(&mut scenario);
            let tickets = ticket::mint(
                &admin_cap,
                TEN,
                b"TEST".to_string(),
                PRICE, ctx
            );
            // First Tx , mint nft
        
                assert!(vector::length(&tickets) == TEN);
                assert!(tickets[0].name() == utf8(b"TEST"));
                assert!(tickets[0].price() == TEN);
                assert!(tickets[0].active() == false);
        

            ts::return_to_sender(&scenario, admin_cap);
        };

        ts::end(scenario);
    }
}