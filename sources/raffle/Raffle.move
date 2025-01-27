#[allow(lint(self_transfer))]

module aynrand::raffle;
 
use aynrand::errors as E;
use aynrand::events;
use aynrand::ticket::{Self, Ticket, AdminCap, Counter};
use std::string::String;
use sui::balance::{Self, Balance};
use sui::clock::{Self, Clock};
use sui::coin::{Self, Coin};
use sui::dynamic_object_field;
use sui::random::{Self, Random};
use sui::sui::SUI;
use sui::table::{Self, Table};
use std::hash::{sha3_256};
use std::bcs::{to_bytes};

const DEFAULT_TICKET_PRICE: u64 = 100_000_000;

public struct Raffle has key, store {
    id: UID,
    tickets: TicketVault,
    prize: PrizePool,
    config: RaffleConfig,
    state: RaffleState,
}

public struct TicketVault has store {
    buyed_tickets: Table<address, Ticket>,
    available_tickets: vector<ID>,
}

public struct PrizePool has store {
    balance: Balance<SUI>,
}

public struct RaffleConfig has store {
    start_time: u64,
    end_time: u64,
    admin: address,
    price: u64,
}

public struct RaffleState has store {
    winner: Option<address>,
    claimed: bool,
}

// Define the possible states of the raffle
public enum RaffleLifecycle has copy, drop {
    NotStarted,
    Active,
    Ended,
    WinnerDrawn,
}

// === Constructors === 

/// Create a new raffle
public fun create(_cap: &AdminCap, start_time: u64, end_time: u64, ctx: &mut TxContext): Raffle {
    Raffle {
        id: object::new(ctx),
        tickets: new_ticket_vault(ctx),
        prize: new_prize_pool(),
        config: new_raffle_config(start_time, end_time, tx_context::sender(ctx)),
        state: new_raffle_state(),
    }
}

/// Setup tickets by admin
public entry fun mint_tickets_to_raffle(
    _cap: &AdminCap,
    raffle: &mut Raffle,
    amount: u64,
    name: String,
    counter: &mut Counter,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    assert!(tx_context::sender(ctx) == raffle.config.admin, E::invalid_owner());
    let state = get_lifecycle_state(raffle, clock);
    assert!(state == RaffleLifecycle::NotStarted, E::invalid_state_transition());

    let mut i = 0;
    
    while (i < amount) {
        let minted_ticket = ticket::mint(_cap, counter, name, i, ctx);
        let ticket_id = object::id(&minted_ticket);
        vector::push_back(&mut raffle.tickets.available_tickets, ticket_id);
        transfer::public_transfer(minted_ticket, tx_context::sender(ctx));
        i = i + 1;
    };
}

/// === Business Logic === 

/// Buy a ticket for a raffle
/// @param raffle_id: ID of the raffle to buy a ticket for
/// @param payment: Payment object containing SUI tokens
/// @param clock: Clock object
/// @param ctx: Transaction context
public entry fun buy_ticket(
    raffle: &mut Raffle,
    mut payment: Coin<SUI>,
    ticket_to_commit: String,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);

    let state = get_lifecycle_state(raffle, clock);
    assert!(state == RaffleLifecycle::Active, E::invalid_state_transition());

    // Validate raffle state
    validate_raffle_state(raffle, clock, &payment);

    // Validate state transition
    validate_state_transition(raffle, clock, RaffleLifecycle::Active);

    // Validate ticket state
    assert!(!table::contains(&raffle.tickets.buyed_tickets, sender), E::duplicated_ticket());
    assert!(!vector::is_empty(&raffle.tickets.available_tickets), E::insufficient_tickets());
    
    // Get and prepare ticket
    let ticket_id = vector::pop_back(&mut raffle.tickets.available_tickets);
    let mut ticket = dynamic_object_field::remove(&mut raffle.id, ticket_id);
    
    commit_ticket(ticket_to_commit, &mut ticket);
    table::add(&mut raffle.tickets.buyed_tickets, sender, ticket);

    // Process payment
    process_payment(raffle, &mut payment, ctx);

    // handle prize pool
    balance::join(&mut raffle.prize.balance, coin::into_balance(payment));

    events::emit_buy_ticket(
        object::uid_to_inner(&raffle.id),
        sender,
        clock::timestamp_ms(clock),
    );
}

fun process_payment(raffle: &Raffle, payment: &mut Coin<SUI>, ctx: &mut TxContext) {
    let payment_value = coin::value(payment);
    if (payment_value > raffle.config.price) {

        let split_amount = payment_value - raffle.config.price;

        let refund = coin::split(payment, split_amount, ctx);
        transfer::public_transfer(refund, tx_context::sender(ctx));
    };
}

fun commit_ticket(ticket_to_commit: String, ticket: &mut Ticket) {
    assert!(is_unique_ticket_number(ticket, ticket_to_commit), E::duplicated_ticket());
    ticket::set_committed(ticket, ticket_to_commit);
}

/// WARNING: Current random number generation is not secure enough for production use.
/// Use a secure random number generator based on RAND, BLS or ZKP.
/// Reference: "Building Random, Fair, and Verifiable Games on Blockchain"
/// https://arxiv.org/pdf/2310.12305
///
/// Draw a winner for the raffle
/// @param raffle: The raffle object to draw a winner for
/// @param clock: Clock object for timing validation
/// @param r: Random object for secure number generation
/// @param ctx: Transaction context for sender info
#[allow(lint(public_random))]
public entry fun draw_winner(raffle: &mut Raffle, clock: &Clock, r: &Random, ctx: &mut TxContext) {
    // Validate state transition
    validate_state_transition(raffle, clock, RaffleLifecycle::Ended);
    assert!(option::is_none(&raffle.state.winner), E::winner_already_drawn());

    // Get total number of tickets
    let ticket_count = table::length(&raffle.tickets.buyed_tickets);
    assert!(ticket_count > 0, E::no_tickets_sold());

    // Generate random index using Sui's Random module
    let mut generator = random::new_generator(r, ctx);
    let random_value = random::generate_u256(&mut generator);
    let random_index = (random_value % (ticket_count as u256) as u64);

    // Get winner address using table entries
    let mut addresses = vector::empty();
    let addr = tx_context::sender(ctx);
    if (table::contains(&raffle.tickets.buyed_tickets, addr)) {
        vector::push_back(&mut addresses, addr);
    };

    // Set winner
    let winner = *vector::borrow(&addresses, random_index);
    assert!(table::contains(&raffle.tickets.buyed_tickets, winner), 0);
    raffle.state.winner = option::some(winner);

    events::emit_winner_drawn(
        object::uid_to_inner(&raffle.id),
        winner,
        clock::timestamp_ms(clock),
    );
}

/// Check if the raffle has started
/// @param raffle: Raffle object
/// @param time: Clock object
/// @return: True if the raffle has started, false otherwise
public fun has_started(raffle: &Raffle, time: &Clock): bool {
    clock::timestamp_ms(time) >= raffle.config.start_time
}

/// Check if the raffle has ended
/// @param raffle: Raffle object
/// @param time: Clock object
/// @return: True if the raffle has ended, false otherwise
public fun has_ended(raffle: &Raffle, time: &Clock): bool {
    clock::timestamp_ms(time) >= raffle.config.end_time
}

/// Check if the payment is sufficient
/// @param payment: Payment object
/// @return: True if the payment is sufficient false otherwise
public fun has_price_below(payment: u64): bool {
    payment >= DEFAULT_TICKET_PRICE
}

/// Checks if the given ticket number is unique (not previously chosen)
/// @param ticket: Reference to the ticket being checked
/// @param candidate: the candidate being compared
/// @return: True if the candidate is unique (not used), false if already taken
public fun is_unique_ticket_number(ticket: &Ticket, candidate: String): bool {

    let ticket_number_bytes = to_bytes(ticket::committed_hash(ticket));
    let ticket_number = sha3_256(ticket_number_bytes);
    let hashed_candidate = sha3_256(to_bytes(&candidate));
    
    (ticket_number != hashed_candidate)
}

/// Process the payment and get the refund if the payment is greater than the ticket price
/// @param payment: Payment object containing SUI tokens
/// @param ctx: Transaction context
public fun payment_refund(payment: &mut Coin<SUI>, ctx: &mut TxContext): Coin<SUI> {
    let payment_value = coin::value(payment);
    let payment_refund = payment_value - DEFAULT_TICKET_PRICE;

    if (payment_refund > 0) {
        coin::split(payment, payment_refund, ctx)
    } else {
        coin::zero(ctx)
    }
}

// Add constructor functions
fun new_ticket_vault(ctx: &mut TxContext): TicketVault {
    TicketVault {
        buyed_tickets: table::new(ctx),
        available_tickets: vector::empty(),
    }
}

fun new_prize_pool(): PrizePool {
    PrizePool {
        balance: balance::zero(),
    }
}

fun new_raffle_config(start_time: u64, end_time: u64, admin: address): RaffleConfig {
    RaffleConfig {
        start_time,
        end_time,
        admin,
        price: DEFAULT_TICKET_PRICE,
    }
}

fun new_raffle_state(): RaffleState {
    RaffleState {
        winner: option::none(),
        claimed: false,
    }
}

#[test_only]
public fun create_with_time_for_testing(
    start_time: u64,
    end_time: u64,
    ctx: &mut TxContext,
): Raffle {
    Raffle {
        id: object::new(ctx),
        tickets: new_ticket_vault(ctx),
        prize: new_prize_pool(),
        config: new_raffle_config(start_time, end_time, tx_context::sender(ctx)),
        state: new_raffle_state(),
    }
}

#[test_only]
public fun test_destroy_raffle(raffle: Raffle) {
    let Raffle {
        id,
        tickets: TicketVault { buyed_tickets, available_tickets: _ },
        prize: PrizePool { balance },
        config: RaffleConfig { start_time: _, end_time: _, admin: _, price: _ },
        state: RaffleState { winner: _, claimed: _ },
    } = raffle;

    table::destroy_empty(buyed_tickets);
    object::delete(id);
    balance::destroy_zero(balance);
}


#[test_only]
public fun test_share_raffle(raffle: Raffle) {
    transfer::share_object(raffle)
}

/// Get current state of the raffle
public fun get_lifecycle_state(raffle: &Raffle, clock: &Clock): RaffleLifecycle {
    if (option::is_some(&raffle.state.winner)) {
        return RaffleLifecycle::WinnerDrawn
    } else if (has_ended(raffle, clock)) {
        RaffleLifecycle::Ended
    } else if (has_started(raffle, clock)) {
        RaffleLifecycle::Active
    } else {
        RaffleLifecycle::NotStarted
    }
}

/// Validate state transition
fun validate_state_transition(raffle: &Raffle, clock: &Clock, expected: RaffleLifecycle) {
    let current_state = get_lifecycle_state(raffle, clock);
    assert!(current_state == expected, E::invalid_state_transition());
}

fun validate_raffle_state(raffle: &Raffle, clock: &Clock, payment: &Coin<SUI>) {
    assert!(!has_started(raffle, clock), E::raffle_started());
    assert!(!has_ended(raffle, clock), E::raffle_ended());
    assert!(has_price_below(coin::value(payment)), E::insufficient_funds());
}
