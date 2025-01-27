#[test_only]
#[allow(unused_use)]
module aynrand::base_test {
    use sui::{ address, random };

    
    const ADMIN_ADDRESS: address = @0xCAFE;
    const USER_ADDRESS_1: address = @0xA1CE;
    const USER_ADDRESS_2: address = @0xB000;

    /// 1 MIST represent 10^-9 Sui
    const DEFAULT_PRICE: u64 = 1_000_000_000;
    const DEFAULT_AMOUNT_TICKETS: u64 = 10;

    const DEFAULT_NAME: vector<u8> = b"TEST";
    const ZERO_COUNT: u64 = 0;

    public fun generate_signers(number: u64): (address, vector<address>) {
        let signers = vector::tabulate!(number, |elem| {
            address::from_u256(elem as u256)}
        );
        (signers[0], signers)
    }

    public fun generate_ten_commitments(): vector<vector<u8>> {
        // Generate harcoded commitments

        let mut commitments = vector::empty<vector<u8>>();
        vector::push_back(&mut commitments, b"0008123350");
        vector::push_back(&mut commitments, b"0007184550");
        vector::push_back(&mut commitments, b"0012254250");
        vector::push_back(&mut commitments, b"0005203650");
        vector::push_back(&mut commitments, b"0010154050");
        vector::push_back(&mut commitments, b"0006224850");
        vector::push_back(&mut commitments, b"0009284450");
        vector::push_back(&mut commitments, b"0011303950");
        vector::push_back(&mut commitments, b"0008153250");
        vector::push_back(&mut commitments, b"0012214750");

        commitments
    }
    

    // Getter testing functions
    #[test_only]
    public fun admin(): address {
        ADMIN_ADDRESS
    }

    #[test_only]
    public fun user(): address {
        USER_ADDRESS_1
    }

    #[test_only]
    public fun user_1(): address {
        USER_ADDRESS_2
    }

    #[test_only]
    public fun default_amount(): u64{
        DEFAULT_AMOUNT_TICKETS
    }

    #[test_only]
    public fun default_price(): u64{
        DEFAULT_PRICE
    }

    

    #[test_only]
    public fun zero_count(): u64{
        ZERO_COUNT
    }

    #[test_only]
    public fun default_name(): vector<u8>{
        DEFAULT_NAME
    }

}