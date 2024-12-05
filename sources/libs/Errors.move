#[allow(unused_function)]

module aynrand::errors;

    /// Constants are opaque, internal
    const EInvalidTicketID: u64 = 0;
    public(package) fun err_invalid_token_id(): u64 { EInvalidTicketID }

    const EInvalidOneTimeWitness: u64 = 1;
    public(package) fun err_invalid_OTW(): u64 { EInvalidOneTimeWitness }