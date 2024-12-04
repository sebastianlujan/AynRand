#[test_only]
#[allow(unused_use)]
module aynrand::aynrand_tests {

    use aynrand::aynrand::{Self as ayn};
    use sui::test_scenario as ts;
    use sui::sui::SUI;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_aynrand() {
        assert!(true, 12);
    }

    #[test, expected_failure(abort_code = ::aynrand::aynrand_tests::ENotImplemented)]
    fun test_aynrand_fail() {

        abort ENotImplemented
    }
}
