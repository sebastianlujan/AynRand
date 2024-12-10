#[allow(lint(self_transfer))]
module aynrand::ticket {

    use std::string::{ String };
    use sui::{ types, package };

    use aynrand::{ events, errors as E};
    use std::debug;

    /// OTW One Time Witness
    /// https://move-book.com/programmability/one-time-witness.html
    public struct TICKET has drop { }

    /// AdminCap delegate to capability to mint tickets
    public struct AdminCap has key {
        id: UID
    }

    // Ticket NFT
    // Ticket Name for the NFT, AYN
    public struct Ticket has key, store {
        id: UID,
        name: String,
        active: bool,
        owner: address,
        index: u64  // Added to track ticket number
    }

    // Constructor one time witness
    fun init(otw: TICKET, ctx: &mut TxContext) {
        assert!(types::is_one_time_witness(&otw), E::invalid_OTW());

        let publisher = package::claim(otw, ctx);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::transfer(AdminCap { id: object::new(ctx) }, tx_context::sender(ctx));
    }

    public fun mint(_cap: &AdminCap, name: String, index: u64, ctx: &mut TxContext): Ticket {
        let owner = tx_context::sender(ctx);
        
        debug::print(&owner);

        let ticket_id = object::new(ctx);
        let ticket_id_object = object::uid_to_inner(&ticket_id);

        let ticket = Ticket {
            id: ticket_id,
            name,
            active: false,
            owner,
            index
        };

        events::emit_new_tickets(ticket_id_object, index);
        ticket
    }

    public entry fun burn(ticket: Ticket, ctx: &mut TxContext) {
        assert!(ticket.owner == tx_context::sender(ctx), E::invalid_owner());

        let Ticket { id, name: _, active: _, owner: _, index: _ } = ticket;
        object::delete(id);
    }

    public entry fun transfer(ticket: Ticket, to: address) {
        transfer::public_transfer(ticket, to);
    }

    public fun name(ticket: &Ticket): &String {
        &ticket.name
    }

    public fun active(ticket: &Ticket): &bool {
        &ticket.active
    }

    public fun owner(nft: &Ticket): &address {
        &nft.owner
    }

    #[test_only]
    public fun test_new_admin_cap(ctx: &mut TxContext): AdminCap {
        AdminCap { id: object::new(ctx) }
    }

    #[test_only]
    public fun test_destroy_admin_cap(admin_cap: AdminCap) {
        let AdminCap { id } = admin_cap;
        object::delete(id);
    }

    #[test_only]
    public fun test_destroy_ticket(ticket: Ticket) {
        let Ticket { id, name: _, active: _, owner: _, index: _ } = ticket;
        object::delete(id);
    }
}