module aynrand::events;

    /// Dependencies
    use sui::event;

    /// Events data
    public struct TicketMinted has copy, drop {
        id: ID,
        index: u64
    }

    public struct TicketPurchased has copy, drop {
        id: ID,
        buyer: address,
        timestamp: u64
    }

    public struct WinnerDrawn has copy, drop {
        id: ID,
        winner: address,
        timestamp: u64
    }

    /// Event emiter
    public fun emit_new_tickets(id: ID, index: u64) {
        event::emit(TicketMinted {id, index});
    }

    public fun emit_buy_ticket(id: ID, buyer: address, timestamp: u64) {
        event::emit(TicketPurchased {id, buyer, timestamp});
    }

    public fun emit_winner_drawn(id: ID, winner: address, timestamp: u64) {
        event::emit(WinnerDrawn {id, winner, timestamp});
    }