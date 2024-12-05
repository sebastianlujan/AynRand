#[test_only]
module aynrand::test_base {
    use sui::{ address };

/*
    public fun before(sender: address): (&mut Scenario, &mut TxContext) {
        let mut scenario = begin(sender);
        let ctx = ts::ctx(&mut scenario);
        (&mut scenario, ctx)
    }
*/
    public fun generate_signers(number: u64): (address, vector<address>) {
        let signers = vector::tabulate!(number, |elem| {
            address::from_u256(elem as u256)}
        );
        (signers[0], signers)
    }
}