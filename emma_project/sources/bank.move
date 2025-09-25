// This module defines the Bank and its operations for the workshop_project.
// It provides functions to create accounts, deposit, withdraw, and transfer funds between accounts.
module workshop_project::bank {

    // Import the coin module from Sui for coin operations.
    use sui::coin;
    // Import account-related types and functions from the account_move module.
    use workshop_project::account_move::{ 
        Account, 
        AccountCap,
        new, 
        get_owner, 
        get_balance_valuation, 
        get_balance_part, 
        add_balance};

    // Import the manager module for BankManagerCap and related functions.
    use workshop_project::manager::{Self,  BankManagerCap};
    // Import balance and table modules from Sui for balance and table management.
    use sui::balance;
    use sui::table;

    // Error code for when an account is not found in the bank.
    const EAccountNotFound: u64 =  100;
    // Error code for when a withdrawal or transfer amount exceeds the available balance.
    const EAmountExceedsBalance: u64 = 101;
    // Error code for when a user account is not found during a transfer.
    const EUserAccountNotFound: u64 = 102;

    // The Bank struct represents the main bank object.
    // It stores all user accounts and tracks the total value.
    public struct Bank has key, store {
        // Unique identifier for the bank object.
        id: UID,
        // Table mapping addresses to Account structs.
        accounts: table::Table<address, Account>,
        // Total value held in the bank (not actively used in logic here).
        value: u64,
    }

    // Initializes the bank and gives the manager capability to the sender.
    // Parameters:
    //   - ctx: The transaction context, required for creating new objects.
    fun init(
        ctx: &mut TxContext,
    ){
        // Create a new BankManagerCap for the bank manager.
        let bank_manager_cap = manager::create(ctx);
        // Transfer the manager capability to the sender of the transaction.
        transfer::public_transfer(bank_manager_cap, ctx.sender());
        // Create the Bank object with a new UID, an empty accounts table, and zero value.
        let bank = Bank {
            id: object::new(ctx),
            accounts: table::new<address, Account>(ctx),
            value: 0
        };

        // Share the bank object so it can be accessed by others.
        transfer::share_object(bank);    
        
    }

    // Creates a new account in the bank for a given owner.
    // Only callable by someone with the BankManagerCap.
    // Parameters:
    //   - _: Reference to the BankManagerCap (not used, just for access control).
    //   - bank: Mutable reference to the Bank object.
    //   - id: An identifier for the account (not used in logic here).
    //   - owner: The address of the new account owner.
    //   - ctx: The transaction context.
    public fun create_account(
        _: &BankManagerCap,
        bank: &mut Bank,
        id: u64,
        owner: address,
        ctx: &mut TxContext
    ){
        // Create a new Account and AccountCap for the owner.
        let (account, accountCap) = new(owner, ctx);
        // Add the new account to the bank's accounts table.
        bank.accounts.add(owner, account);
        // Transfer the AccountCap to the owner so they can manage their account.
        transfer::public_transfer(accountCap, owner);
    }

    // Deposits SUI coins into the sender's account in the bank.
    // Only callable by someone with the AccountCap.
    // Parameters:
    //   - _: Reference to the AccountCap (not used, just for access control).
    //   - bank: Mutable reference to the Bank object.
    //   - coin: The SUI coin to deposit.
    //   - ctx: The transaction context.
    public fun deposit(
        _: &AccountCap,
        bank: &mut Bank,
        coin: coin::Coin<sui::sui::SUI>,
        ctx: &mut TxContext
    ){
        // Convert the coin to a balance and add it to the sender's account.
        bank.accounts[ctx.sender()].add_balance(coin.into_balance());
    }

    // Withdraws a specified amount of SUI from the sender's account in the bank.
    // Only callable by someone with the AccountCap.
    // Parameters:
    //   - _: Reference to the AccountCap (not used, just for access control).
    //   - bank: Mutable reference to the Bank object.
    //   - amount: The amount to withdraw.
    //   - ctx: The transaction context.
    public fun withdraw(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        ctx: &mut TxContext
    ){
        // Ensure the sender's account has enough balance to withdraw the requested amount.
        assert!(bank.accounts[ctx.sender()].get_balance_valuation() >= amount, EAmountExceedsBalance);
        // Split the requested amount from the sender's account balance.
        let amount_to_be_withdrawn = bank.accounts[ctx.sender()].get_balance_part(amount);
        // Convert the balance to a coin and transfer it to the sender.
        transfer::public_transfer(
            coin::from_balance(amount_to_be_withdrawn, ctx),
            ctx.sender()
        )
    }

    // Transfers a specified amount of SUI from the sender's account to another user's account in the bank.
    // Only callable by someone with the AccountCap.
    // Parameters:
    //   - _: Reference to the AccountCap (not used, just for access control).
    //   - bank: Mutable reference to the Bank object.
    //   - amount: The amount to transfer.
    //   - recepient: The address of the recipient account.
    //   - ctx: The transaction context.
    public fun transfer(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        recepient: address,
        ctx: &mut TxContext
    ){
        // Check if the recipient account exists in the bank; abort if not found.
        if(!bank.accounts.contains(recepient)){
            abort EUserAccountNotFound;
        };

        // Split the requested amount from the sender's account balance.
        let balance_to_send = bank.accounts[ctx.sender()].get_balance_part(amount);
        // Add the split balance to the recipient's account.
        bank.accounts[recepient].add_balance(balance_to_send);
    }
}