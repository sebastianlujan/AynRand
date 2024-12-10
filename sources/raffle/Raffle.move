#[allow(lint(self_transfer))]

module aynrand::raffle;

use aynrand::errors as E;
use aynrand::events;
use aynrand::ticket::Ticket;
use sui::balance::{Self, Balance};
use sui::clock::{Self, Clock};
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::table::{Self, Table};

const TICKET_PRICE: u64 = 100_000_000;

public struct Raffle has key, store {
    id: UID,
    tickets: Table<address, Ticket>,
    winner: Option<address>,
    prize_pool: Balance<SUI>,
    start_time: u64,
    end_time: u64,
    admin: address,
    claimed: bool,
    ticket_count: u64,
}

/// Buy a ticket for a raffle
/// @param raffle_id: ID of the raffle to buy a ticket for
/// @param payment: Payment object containing SUI tokens
/// @param clock: Clock object
/// @param ctx: Transaction context
public entry fun buy_ticket(
    raffle: &mut Raffle,
    mut payment: Coin<SUI>,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    //Check if the raffle has not started and has not ended
    assert!(!has_started(raffle, clock), E::raffle_started());
    assert!(!has_ended(raffle, clock), E::raffle_ended());
    assert!(has_price_below(coin::value(&payment)), E::insufficient_funds());

    let sender = tx_context::sender(ctx);
    assert!(table::contains(&raffle.tickets, sender), E::duplicate_ticket());

    let payment_value = coin::value(&payment);
    if (payment_value > TICKET_PRICE) {
        let refund = coin::split(&mut payment, payment_value - TICKET_PRICE, ctx);
        transfer::public_transfer(refund, sender);
    };

    // Add payment to prize pool
    balance::join(&mut raffle.prize_pool, coin::into_balance(payment));

    // Emit event
    events::emit_buy_ticket(
        object::uid_to_inner(&raffle.id),
        sender,
        clock::timestamp_ms(clock),
    );
}

/// Check if the raffle has started
/// @param raffle: Raffle object
/// @param time: Clock object
/// @return: True if the raffle has started, false otherwise
public fun has_started(raffle: &Raffle, time: &Clock): bool {
    clock::timestamp_ms(time) >= raffle.start_time
}

/// Check if the raffle has ended
/// @param raffle: Raffle object
/// @param time: Clock object
/// @return: True if the raffle has ended, false otherwise
public fun has_ended(raffle: &Raffle, time: &Clock): bool {
    clock::timestamp_ms(time) >= raffle.end_time
}

/// Check if the payment is below the ticket price
/// @param payment: Payment object
/// @return: True if the payment is below the ticket price, false otherwise
public fun has_price_below(payment: u64): bool {
    payment < TICKET_PRICE
}

/// Process the payment and get the refund if the payment is greater than the ticket price
/// @param payment: Payment object containing SUI tokens
/// @param ctx: Transaction context
public fun payment_refund(payment: &mut Coin<SUI>, ctx: &mut TxContext): Coin<SUI> {
    let payment_value = coin::value(payment);
    let payment_refund = payment_value - TICKET_PRICE;

    if (payment_refund > 0) {
        coin::split(payment, payment_refund, ctx)
    } else {
        coin::zero(ctx)
    }
}
