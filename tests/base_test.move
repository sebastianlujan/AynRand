#[test_only]
module aynrand::base_test {
    use sui::{ address };

/*
    public fun before(sender: address): (&mut Scenario, &mut TxContext) {
        let mut scenario = begin(sender);
        let ctx = ts::ctx(&mut scenario);
        (&mut scenario, ctx)
    }
*/
    
    const ADMIN_ADDRESS: address = @0xCAFE;

    /// 1 MIST represent 10^-9 Sui
    //const DEFAULT_AMOUNT: u64 = 1_000_000_000;
    const DEFAULT_AMOUNT_TICKETS: u64 = 10;
    const DEFAULT_NAME: vector<u8> = b"TEST";

    public fun generate_signers(number: u64): (address, vector<address>) {
        let signers = vector::tabulate!(number, |elem| {
            address::from_u256(elem as u256)}
        );
        (signers[0], signers)
    }

    // Getter testing functions
    #[test_only]
    public fun admin(): address {
        ADMIN_ADDRESS
    }

    #[test_only]
    public fun default_amount(): u64{
        DEFAULT_AMOUNT_TICKETS
    }

    #[test_only]
    public fun default_name(): vector<u8>{
        DEFAULT_NAME
    }

}