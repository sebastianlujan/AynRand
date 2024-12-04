#[allow(unused_function)]
module aynrand::events;

    /// Dependencies
    use sui::event;

    /// Events data
    public struct TicketMinted has copy, drop {
        id: ID,
        index: u64
    }
    
    /// Event emiter
    public(package) fun emit_new_ticket(id: ID, ticket: u64) {
        event::emit(TicketMinted {id, index: ticket });
    }
