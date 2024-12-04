#[allow(unused_function)]

module aynrand::errors;

    /// Constants are opaque, internal
    const EInvalidTicketID: u64 = 0;
    fun err_invalid_token_id() { abort EInvalidTicketID }