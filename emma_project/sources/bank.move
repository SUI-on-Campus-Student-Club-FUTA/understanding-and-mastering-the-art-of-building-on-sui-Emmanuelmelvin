module workshop_project::bank {

    use sui::coin;
    use workshop_project::account_move::{ 
        Account, 
        AccountCap,
        new, 
        get_owner, 
        get_balance_valuation, 
        get_balance_part, 
        add_balance};

    use workshop_project::manager::{Self,  BankManagerCap};
    use sui::balance;
    use sui::table;

    const EAccountNotFound: u64 =  100;
    const EAmountExceedsBalance: u64 = 101;
    const EUserAccountNotFound: u64 = 102;

    public struct Bank has key, store {
        id: UID,
        accounts: table::Table<address, Account>,
        value: u64,
    }

    fun init(
        ctx: &mut TxContext,
    ){
        let bank_manager_cap = manager::create(ctx);
        transfer::public_transfer(bank_manager_cap, ctx.sender());
        let bank = Bank {
            id: object::new(ctx),
            accounts: table::new<address, Account>(ctx),
            value: 0
        };

        transfer::share_object(bank);    
        
    }

    public fun create_account(
        _: &BankManagerCap,
        bank: &mut Bank,
        id: u64,
        owner: address,
        ctx: &mut TxContext
    ){
      
        let (account, accountCap) = new(owner, ctx);
        bank.accounts.add(owner, account);
        transfer::public_transfer(accountCap, owner);
    }

    public fun deposit(
        _: &AccountCap,
        bank: &mut Bank,
        coin: coin::Coin<sui::sui::SUI>,
        ctx: &mut TxContext
    ){
        bank.accounts[ctx.sender()].add_balance(coin.into_balance());
    }

    public fun withdraw(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        ctx: &mut TxContext
    ){
        assert!(bank.accounts[ctx.sender()].get_balance_valuation() >= amount, EAmountExceedsBalance);
        let amount_to_be_withdrawn = bank.accounts[ctx.sender()].get_balance_part(amount);
        transfer::public_transfer(
            coin::from_balance(amount_to_be_withdrawn, ctx),
            ctx.sender()
        )
    }

    public fun transfer(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        recepient: address,
        ctx: &mut TxContext
    ){
        if(!bank.accounts.contains(recepient)){
            abort EUserAccountNotFound;
        };

        let balance_to_send = bank.accounts[ctx.sender()].get_balance_part(amount);
        bank.accounts[recepient].add_balance(balance_to_send);
    }
}