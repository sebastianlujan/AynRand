module aynrand::prize_pool {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    /// Holds the prize pool balance
    public struct PrizePool has store {
        balance: Balance<SUI>,
    }

    /// Create a new empty prize pool
    public fun new(): PrizePool {
        PrizePool {
            balance: balance::zero(),           
        }
    }

    /// Add funds to the prize pool
    public fun add_funds(pool: &mut PrizePool, payment: Coin<SUI>) {
        balance::join(&mut pool.balance, coin::into_balance(payment));
    }

    /// Get current prize pool amount
    public fun get_amount(pool: &PrizePool): u64 {
        balance::value(&pool.balance)
    }

    /// Check if prize pool has funds
    public fun has_funds(pool: &PrizePool): bool {
        balance::value(&pool.balance) > 0
    }

    /// Withdraw all funds from prize pool
    public fun withdraw_all(pool: &mut PrizePool, ctx: &mut TxContext): Coin<SUI> {
        coin::from_balance(balance::withdraw_all(&mut pool.balance), ctx)
    }

    #[test_only]
    public fun destroy_zero(pool: PrizePool) {
        let PrizePool { balance } = pool;
        balance::destroy_zero(balance);
    }
}