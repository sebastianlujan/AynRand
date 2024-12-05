#[test_only]
module aynrand::ticket_test {
    use sui::test_scenario::{Self as ts};
    // use aynrand::test_base::{Self as tb};
    
    use aynrand::ticket;
    use std::{string::utf8};

    /// 1 MIST represent 10^-9 Sui
    const PRICE: u64 = 1_000_000_000;
    const ADMIN: address = @0xCAFE;
    const TEN_TICKETS: u64 = 10;

    #[test]
    fun test_mint_ticket() {

        let mut scenario = ts::begin(ADMIN);
        let ctx = ts::ctx(&mut scenario);

        
        
        /// It should be minted an NFT
        ts::next_tx(&mut scenario, @0x1);
        {
            let ticket = ts::take_from_sender<ticket::Ticket>(&mut scenario);
            assert!(ticket::name(&ticket) == utf8(b"test"));
            assert!(ticket::price(&ticket) == PRICE);
            ts::return_to_sender(&scenario, ticket);
        };
        ts::end(scenario);
        
    }
}