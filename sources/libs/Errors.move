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

    /// Error when trying to draw winner before raffle has ended. 
    /// This ensures fairness by preventing early winner selection.
    const ERaffleNotEnded: u64 = 8;
    public(package) fun raffle_not_ended(): u64 { ERaffleNotEnded }

    /// Error when attempting to redraw a winner. 
    /// This prevents manipulation by ensuring only one winner can be drawn.
    const EWinnerAlreadyDrawn: u64 = 9;
    public(package) fun winner_already_drawn(): u64 { EWinnerAlreadyDrawn }

    /// Error when trying to draw winner with no valid tickets.
    /// This ensures there are actual participants in the raffle.
    const ENoTicketsSold: u64 = 10;
    public(package) fun no_tickets_sold(): u64 { ENoTicketsSold }

    /// Error when attempting an invalid state transition
    const EInvalidStateTransition: u64 = 11;
    public(package) fun invalid_state_transition(): u64 { EInvalidStateTransition }

    /// Error when trying to claim prize when not the winner
    const ENotWinner: u64 = 12;
    public(package) fun not_winner(): u64 { ENotWinner }

    /// Error when prize has already been claimed
    const EPrizeAlreadyClaimed: u64 = 13;
    public(package) fun prize_already_claimed(): u64 { EPrizeAlreadyClaimed }

    /// Error when prize pool is empty
    const EInsufficientPrizePool: u64 = 14;
    public(package) fun insufficient_prize_pool(): u64 { EInsufficientPrizePool }

    /// Error when unauthorized address attempts to claim prize
    const ENotAuthorizedToClaim: u64 = 15;
    public(package) fun not_authorized_to_claim(): u64 { ENotAuthorizedToClaim }
