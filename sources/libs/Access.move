#[allow(unused_function)]
module aynrand::access {

    /// - Capabilities, similar to modifiers in Solidity
    /// - Capabilities have a module scope
    /// - Implemented a custom eative framework to make it modular

    /// Cross-module wrapper, for admin capability, similar to onlyOwner
    /// https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-three/lessons/2_intro_to_generics.md
    public struct AdminCap<phantom T> has key, store {
        id: UID
    }

    /// Only the admin can call one time the constructor
    /// https://move-book.com/programmability/one-time-witness.htmlcan only be instantiated within its defining module 'aynrand::access'

    #[allow(unused_variable)]
    // Initialize admin capability for a specific module
    public fun init_admin<T>(ctx: &mut TxContext): AdminCap<T> { 
        AdminCap { id: object::new(ctx) }
    }
}