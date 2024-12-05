#[allow(unused_function)]

module aynrand::ticket;

    use std::string::String;
    use sui::{package, table, display, types, url::{Url}};
    use aynrand::{ events, access, errors };

    /// OTW One Time Witness
    /// https://move-book.com/programmability/one-time-witness.html
    public struct TICKET has drop { }

    /// Ticket NFT
    public struct TicketNFT has key, store {
        id: UID,
        details: TicketDetails,
    }

    /// Ticket Details
    public struct TicketDetails has store, drop {
        /// Object ID
        id: ID,
        /// Ticket Index, 
        index: u32,
        /// Ticket Name for the NFT, AYN
        name: String,
        /// Price
        price: u64
    }

    /// Constructor one time witness
    fun init(otw: TICKET, ctx: &mut TxContext) {
        /// CEI, Check,Effect,Interaction pattern, 
        assert!(types::is_one_time_witness(&otw), errors::err_invalid_OTW());

        let deployer = ctx.sender();
        let adminCap = access::init_admin<TICKET>(ctx);

        transfer::public_transfer(adminCap, deployer);
    }
}