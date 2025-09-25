module workshop_project::account_move {

    use sui::balance;
    use sui::coin;


    const EInsufficientFunds: u64 = 101;

    public struct Account has store {
        owner: address,
        balance: balance::Balance<sui::sui::SUI>,
    }

    public struct AccountCap has key, store {
        id: UID,
    }

    public(package) fun new(
        owner: address,
        ctx: &mut TxContext
        ): (Account, AccountCap) {

        let account = Account {
            owner,
            balance: balance::zero<sui::sui::SUI>()
        };

        let cap = AccountCap{
            id: object::new(ctx)
        };

        (account, cap)
    }

    public fun get_owner(
        account: &Account
    ): address{
        account.owner
    }

    public(package) fun get_balance_valuation(
        account: &Account
    ): u64 {
        account.balance.value()
    }

    /* public(package) fun get_balance(
        account: &Account

    ): balance::Balance<sui::sui::SUI>{
        account.balance
    } */

    public(package) fun get_balance_part(
        account: &mut Account,
        value: u64
    ): balance::Balance<sui::sui::SUI>{
        assert!(account.balance.value() > value, EInsufficientFunds);
        account.balance.split(value)
    }

    public(package) fun add_balance(
        account: &mut Account,
        balance: balance::Balance<sui::sui::SUI>
    ){
        account.balance.join(balance);
    }
}
