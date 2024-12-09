module aynrand::events;

    /// Dependencies
    use sui::event;

    /// Events data
    public struct TicketMinted has copy, drop {
        id: ID,
        index: u64
    }
    
    /// Event emiter
    public fun emit_new_tickets(id: ID, index: u64) {
        event::emit(TicketMinted {id, index});
    }