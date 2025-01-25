//#[allow(lint(self_transfer))]
#[allow(unused_function)]

module aynrand::ticket {

    use std::string::{ String, utf8 };
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
        committed_hash: String,  // Added to track ticket number
        counter: u64,
        owner: address,
        active: bool,
    }

    #[allow(unused_variable)]
    public struct Counter has key, store {
        id: UID,
        last_counter: u64
    }

    // === Initialization ===

    // Constructor one time witness, called once on deployment
    fun init(otw: TICKET, ctx: &mut TxContext) {
        assert!(types::is_one_time_witness(&otw), E::invalid_OTW());

        let publisher = package::claim(otw, ctx);
        let admin_cap = AdminCap { id: object::new(ctx) };
        let admin = tx_context::sender(ctx);
    

        transfer::public_transfer(publisher, admin);
        transfer::transfer(admin_cap, admin);
    }

    // === Constructors ===

    // Only the owner can mint tickets via AdminCap
    #[allow(unused_variable)]
    public fun mint(_cap: &AdminCap, counter: &mut Counter, name: String, index: u64, ctx: &mut TxContext): Ticket {
        let owner = tx_context::sender(ctx);
    
        let ticket_id = object::new(ctx);
        let ticket_id_object = object::uid_to_inner(&ticket_id);

        let ticket = Ticket {
            id: ticket_id,
            name,
            committed_hash: utf8(b""),
            counter:  0,
            owner,
            active: true,
        };
    
        events::emit_new_tickets(ticket_id_object, index);
        ticket
    }

    // internal function to increment ticket index
    public fun increment(self: &mut Ticket, counter: &mut Counter) {
        counter.last_counter = self.counter;
        self.counter = self.counter + 1;
    }

    // === Destructors === 
    
    // Only the owner can burn the ticket via AdminCap
    public entry fun burn(ticket: Ticket, ctx: &mut TxContext) {
        assert!(ticket.owner == tx_context::sender(ctx), E::invalid_owner());

        let Ticket { id, name: _, committed_hash: _, counter: _, owner: _, active: _} = ticket;
        object::delete(id);
    }

    // Transfer ticket to raffle
    public entry fun transfer(self: Ticket, raffle: address) {
        transfer::public_transfer(self, raffle);
    }

    // === Accessors ===
    public fun committed_hash(self: &Ticket): &String {
        &self.committed_hash
    }

    public fun counter(self: &Ticket): &u64 {
        &self.counter
    }

    public fun last_counter(self: &Counter): &u64 {
        &self.last_counter
    }


    public fun name(self: &Ticket): &String {
        &self.name
    }

    public fun owner(self: &Ticket): &address {
        &self.owner
    }

    fun set_counter(self: &mut Counter, last_counter: u64) {
        self.last_counter = last_counter;
    }

    public fun set_committed(self: &mut Ticket, number: String) {
        self.committed_hash = number;
    }

    // === Predicates ===
    public fun is_active(self: &Ticket): &bool {
        &self.active
    }

    // === Tests Only ===
    #[test_only]
    public fun test_new_admin_cap(ctx: &mut TxContext) {
        let admin_cap = AdminCap { 
            id: object::new(ctx) 
        };
        transfer::transfer(admin_cap, ctx.sender());
    }

    #[test_only]
    public fun test_mint_ticket(admin_cap: AdminCap, counter: &mut Counter, name: String, index: u64, ctx: &mut TxContext) {
        let ticket = mint(&admin_cap, counter, name, index, ctx);
        transfer::transfer(admin_cap, ctx.sender());
        transfer::transfer(ticket, ctx.sender())
    }    

    #[test_only]
    public fun test_new_counter(ctx: &mut TxContext) {
        let counter = Counter {
            id: object::new(ctx),
            last_counter: 0
        };
        transfer::transfer(counter, ctx.sender());
    }
    
    #[test_only]
    public fun test_destroy_admin_cap(_cap: AdminCap) {
        let AdminCap { id } = _cap;
        object::delete(id)
    }

    #[test_only]
    public fun test_burn_ticket(self: Ticket, ctx: &mut TxContext) {
        burn(self, ctx);
    }
}