// This module defines the Account system for the workshop_project.
// It provides structures and functions to manage user accounts and their balances on Sui.
module workshop_project::account_move {

    // Import the balance module from Sui, which provides balance management utilities.
    use sui::balance;
    // Import the coin module from Sui, which provides coin-related utilities (not directly used here).
    use sui::coin;


    // Error code for insufficient funds. Used in assertions to signal not enough balance.
    const EInsufficientFunds: u64 = 101;

    // The Account struct represents a user account with an owner and a SUI balance.
    public struct Account has store {
        // The address of the account owner.
        owner: address,
        // The balance of SUI tokens held by this account.
        balance: balance::Balance<sui::sui::SUI>,
    }

    // The AccountCap struct is a capability object for account management.
    // It is used to control access to account operations.
    public struct AccountCap has key, store {
        // Unique identifier for the capability object.
        id: UID,
    }

    // Creates a new Account and its associated AccountCap.
    // Only callable within the package.
    // Parameters:
    //   - owner: The address that will own the new account.
    //   - ctx: The transaction context, required for creating new objects.
    // Returns: A tuple of (Account, AccountCap).
    public(package) fun new(
        owner: address,
        ctx: &mut TxContext
        ): (Account, AccountCap) {

        // Initialize the Account struct with the given owner and a zero SUI balance.
        let account = Account {
            owner,
            balance: balance::zero<sui::sui::SUI>()
        };

        // Create a new AccountCap with a unique ID using the transaction context.
        let cap = AccountCap{
            id: object::new(ctx)
        };

        // Return the new account and its capability.
        (account, cap)
    }

    // Returns the owner address of the given account.
    // Parameters:
    //   - account: Reference to the Account struct.
    // Returns: The address of the account owner.
    public fun get_owner(
        account: &Account
    ): address{
        account.owner
    }

    // Returns the numeric value of the account's SUI balance.
    // Only callable within the package.
    // Parameters:
    //   - account: Reference to the Account struct.
    // Returns: The balance as a u64 value.
    public(package) fun get_balance_valuation(
        account: &Account
    ): u64 {
        account.balance.value()
    }

    /*
    // (Commented out) Returns the full balance object of the account.
    // Only callable within the package.
    // Parameters:
    //   - account: Reference to the Account struct.
    // Returns: The Balance object.
    public(package) fun get_balance(
        account: &Account
    ): balance::Balance<sui::sui::SUI>{
        account.balance
    }
    */

    // Splits a specified amount from the account's balance and returns it as a new Balance object.
    // Only callable within the package.
    // Parameters:
    //   - account: Mutable reference to the Account struct.
    //   - value: The amount to split from the balance.
    // Returns: A Balance object containing the split amount.
    public(package) fun get_balance_part(
        account: &mut Account,
        value: u64
    ): balance::Balance<sui::sui::SUI>{
        // Ensure the account has more than the requested value; otherwise, abort with error.
        assert!(account.balance.value() > value, EInsufficientFunds);
        // Split the specified value from the account's balance.
        account.balance.split(value)
    }

    // Adds the given Balance object to the account's balance.
    // Only callable within the package.
    // Parameters:
    //   - account: Mutable reference to the Account struct.
    //   - balance: The Balance object to add.
    public(package) fun add_balance(
        account: &mut Account,
        balance: balance::Balance<sui::sui::SUI>
    ){
        // Join (add) the provided balance to the account's balance.
        account.balance.join(balance);
    }
}
