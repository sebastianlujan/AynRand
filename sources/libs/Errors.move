module aynrand::errors;

    /// Constants are opaque, internal
    const EInvalidTicketID: u64 = 0;
    public(package) fun invalid_token_id(): u64 { EInvalidTicketID }

    const EInvalidOneTimeWitness: u64 = 1;
    public(package) fun invalid_OTW(): u64 { EInvalidOneTimeWitness }

    const EInvalidOwner: u64 = 2;
    public(package) fun invalid_owner(): u64 { EInvalidOwner }

    const EInsufficientFunds: u64 = 3;
    public(package) fun insufficient_funds(): u64 { EInsufficientFunds }

    const ERaffleHasStarted: u64 = 4;
    public(package) fun raffle_started(): u64 { ERaffleHasStarted }
    
    const ERaffleHasEnded: u64 = 5;
    public(package) fun raffle_ended(): u64 { ERaffleHasEnded }
    
    const EDuplicateTicket: u64 = 6;
    public(package) fun duplicate_ticket(): u64 { EDuplicateTicket }

    const EInsufficientTickets: u64 = 7;
    public(package) fun insufficient_tickets(): u64 { EInsufficientTickets }

    const ERaffleNotEnded: u64 = 8;
    public(package) fun raffle_not_ended(): u64 { ERaffleNotEnded }

    const EWinnerAlreadyDrawn: u64 = 9;
    public(package) fun winner_already_drawn(): u64 { EWinnerAlreadyDrawn }

    const ENoTicketsSold: u64 = 10;
    public(package) fun no_tickets_sold(): u64 { ENoTicketsSold }
