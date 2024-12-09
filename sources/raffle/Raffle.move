#[allow(lint(self_transfer))]
module aynrand::raffle {
    use sui::sui::SUI;
    use sui::coin::{ Self, Coin };
    use sui::clock::{Self, Clock };

    use aynrand::errors as E;

    const TICKET_PRICE: u64 = 100_000_000;
    
    public struct Raffle has key, store {
        id: UID,
        //admin: address,
        players: vector<address>,
        start_time: u64,
        end_time: u64,
        //winner_ticket: u64,
        //is_active: bool,
    }

    /// Buy a ticket for a raffle
    /// @param raffle_id: ID of the raffle to buy a ticket for
    /// @param payment: Payment object containing SUI tokens
    public fun buy_ticket(
        raffle: &mut Raffle,
        payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert!(has_started(raffle, clock), E::raffle_started());
        assert!(has_ended(raffle, clock), E::raffle_ended());
        assert!(has_valid_price(coin::value(&payment)), E::invalid_price());

        vector::push_back(&mut raffle.players, tx_context::sender(ctx));
        transfer::public_transfer(payment, tx_context::sender(ctx));
    }

    public fun has_started(raffle: &Raffle, time: &Clock): bool {
        clock::timestamp_ms(time) >= raffle.start_time
    }

    public fun has_ended(raffle: &Raffle, time: &Clock): bool {
        clock::timestamp_ms(time) >= raffle.end_time
    }

    public fun has_valid_price(payment: u64): bool {
        payment == TICKET_PRICE
    }
}