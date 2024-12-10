#[test_only]
#[allow(unused_use)]
module aynrand::ticket_test;

use aynrand::base_test as tb;
use aynrand::ticket::{Self, Ticket, AdminCap};
use std::debug;
use std::string::utf8;
use sui::test_scenario as ts;

#[test]
fun test_mint_ticket_flow() {
    let admin = tb::admin();
    let mut scenario = ts::begin(admin);

    let scenario_mut = &mut scenario;
    ts::next_tx(scenario_mut, admin);

    // Create AdminCap role
    let admin_cap = ticket::test_new_admin_cap(ts::ctx(&mut scenario));

    let ticket = ticket::mint(
        &admin_cap, 
        utf8(b"TEST"),
        tb::default_amount(),
        ts::ctx(&mut scenario)
    );
    ticket::test_destroy_ticket(ticket);
    ticket::test_destroy_admin_cap(admin_cap);

    ts::end(scenario);
}

//#[allow(unused_field)]
//fun test_buy_ticket(){}
//#[allow(unused_field)]
//fun test_activate_ticket(){}
