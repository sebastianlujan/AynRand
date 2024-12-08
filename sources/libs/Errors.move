module aynrand::errors;

    /// Constants are opaque, internal
    const EInvalidTicketID: u64 = 0;
    public(package) fun invalid_token_id(): u64 { EInvalidTicketID }

    const EInvalidOneTimeWitness: u64 = 1;
    public(package) fun invalid_OTW(): u64 { EInvalidOneTimeWitness }

    const EInvalidOwner: u64 = 2;
    public(package) fun invalid_owner(): u64 { EInvalidOwner }

    const EInvalidPrice: u64 = 3;
    public(package) fun invalid_price(): u64 { EInvalidPrice }

    const ERaffleHasStarted: u64 = 5;
    public(package) fun raffle_started(): u64 { ERaffleHasStarted }
    
    const ERaffleHasEnded: u64 = 4;
    public(package) fun raffle_ended(): u64 { ERaffleHasEnded }
    