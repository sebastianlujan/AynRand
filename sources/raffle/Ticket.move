module aynrand::ticket {

    use std::string::{ String };
    use sui::{ types };

    //use sui::coin::{ Self, Coin};
    //use sui::sui::SUI;

    use aynrand::{ events, errors as err};

    /// OTW One Time Witness
    /// https://move-book.com/programmability/one-time-witness.html
    public struct TICKET has drop { }

    public struct AdminCap has key{
        id: UID
    }

    // Ticket NFT
    // Ticket Name for the NFT, AYN
    public struct Ticket has key, store {
        id: UID,
        name: String,
        is_active: bool
    }

    // Constructor one time witness
    fun init(otw: TICKET, ctx: &mut TxContext) {
        assert!(types::is_one_time_witness(&otw), err::invalid_OTW());

        let adminCap = AdminCap { id: object::new(ctx) };
        transfer::transfer(adminCap, ctx.sender())
    }

    public entry fun mint(_: &AdminCap, amount: u64, name: String, ctx: &mut TxContext) {
        let mut i = 0;
        while(i < amount) {
            let ticket_id = object::new(ctx);
            let ticket_id_object = object::uid_to_inner(&ticket_id);
        
            let ticket = Ticket {
                id: ticket_id,
                name,
                is_active: false
            };

            // Transfer the ticket directly to the sender
            transfer::transfer(ticket, tx_context::sender(ctx));

            // Emit event for the new ticket
            events::emit_new_tickets(ticket_id_object, i);
            i = i + 1;
        }
    }

    public fun burn(tick: Ticket, _: &mut TxContext){
        let Ticket { 
            id,
            name: _,
            is_active: _,
        }  = tick;
        object::delete(id);
    }

    public fun transfer(ticket: Ticket, to: address, _: &mut TxContext){
        transfer::public_transfer(ticket, to);
    }

    // Getter testing functions
    #[test_only]
    public fun name(nft: &Ticket): &String {
        &nft.name
    }

    #[test_only]
    public fun active(nft: &Ticket): &bool {
        &nft.is_active
    }
}