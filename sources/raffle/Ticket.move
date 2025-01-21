//#[allow(lint(self_transfer))]
module aynrand::ticket {

    use std::string::{ String };
    use sui::{ types, package };

    use aynrand::{ events, errors as E};

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

    // Constructor one time witness, called once on deployment
    fun init(otw: TICKET, ctx: &mut TxContext) {
        assert!(types::is_one_time_witness(&otw), E::invalid_OTW());

        let publisher = package::claim(otw, ctx);
        let admin_cap = AdminCap { id: object::new(ctx) };

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    // Mint a new ticket, can be called by the admin cap
    public fun mint(_cap: &AdminCap, name: String, index: u64, ctx: &mut TxContext): Ticket {
        let owner = tx_context::sender(ctx);
    
        let ticket_id = object::new(ctx);
        let ticket_id_object = object::uid_to_inner(&ticket_id);

        let ticket = Ticket {
            id: ticket_id,
            name: name,
            active: true,
            owner: owner,
            index: index
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

    public fun index(ticket: &Ticket): &u64 {
        &ticket.index
    }

    public fun name(ticket: &Ticket): &String {
        &ticket.name
    }

    public fun owner(nft: &Ticket): &address {
        &nft.owner
    }

    public fun is_active(ticket: &Ticket): &bool {
        &ticket.active
    }

    #[test_only]
    public fun test_new_admin_cap(ctx: &mut TxContext) {
        let admin_cap = AdminCap { 
            id: object::new(ctx) 
        };
        transfer::transfer(admin_cap, ctx.sender());
    }

    #[test_only]
    public fun test_mint_ticket(admin_cap: AdminCap, name: String, index: u64, ctx: &mut TxContext) {
        let ticket = mint(&admin_cap, name, index, ctx);
        transfer::transfer(admin_cap, ctx.sender());
        transfer::transfer(ticket, ctx.sender())

    }

    #[test_only]
    public fun test_destroy_admin_cap(admin_cap: AdminCap) {
        let AdminCap { id } = admin_cap;
        object::delete(id)
    }

    #[test_only]
    public fun test_burn_ticket(ticket: Ticket, ctx: &mut TxContext) {
        burn(ticket, ctx)
    }
}