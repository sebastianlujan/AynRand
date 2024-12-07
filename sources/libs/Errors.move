module aynrand::errors;

    /// Constants are opaque, internal
    const EInvalidTicketID: u64 = 0;
    public(package) fun invalid_token_id(): u64 { EInvalidTicketID }

    const EInvalidOneTimeWitness: u64 = 1;
    public(package) fun invalid_OTW(): u64 { EInvalidOneTimeWitness }

    #[allow(unused_const)]
    const EInvalidPrice: u64 = 3;
    public(package) fun invalid_price(): u64 { EInvalidOneTimeWitness }

    