// This module defines the BankManagerCap and related functions for managing bank capabilities.
// It provides ways to create, transfer, and delete manager capabilities in the system.
module workshop_project::manager {
    // The BankManagerCap struct represents a capability for managing the bank.
    // It is a key object that allows privileged operations.
    public struct BankManagerCap has key, store {
        // Unique identifier for the capability object.
        id: UID
    }

    // Creates a new BankManagerCap object.
    // Only callable within the package.
    // Parameters:
    //   - ctx: The transaction context, required for creating new objects.
    // Returns: A new BankManagerCap object.
    public(package) fun create(
        ctx: &mut TxContext
    ):BankManagerCap{
        // Create a new BankManagerCap with a unique ID using the transaction context.
        BankManagerCap{
            id: object::new(ctx)
        }
    }


    // Creates a new BankManagerCap and transfers it to the specified address.
    // Parameters:
    //   - _: Reference to an existing BankManagerCap (not used, just for access control).
    //   - address: The address to transfer the new capability to.
    //   - ctx: The transaction context, required for creating new objects.
    public fun create_and_transfer(
        _: &BankManagerCap,
        address: address,
        ctx: &mut TxContext
    ){
        // Create a new BankManagerCap and transfer it to the given address.
        transfer::public_transfer(
        BankManagerCap{
            id: object::new(ctx)
        },
        address
        )
    }

    // Transfers an existing BankManagerCap to another address.
    // Parameters:
    //   - cap: The BankManagerCap object to transfer.
    //   - address: The address to transfer the capability to.
    public fun transfer(
        cap: BankManagerCap,
        address: address,
    ){
        // Transfer the capability to the specified address.
        transfer::public_transfer(
            cap,
            address
        )
    }

    // Deletes a BankManagerCap object, removing its capability.
    // Parameters:
    //   - cap: The BankManagerCap object to delete.
    public fun delete(
        cap: BankManagerCap
    ){
        // Destructure the cap to get its id and delete the id object.
        let BankManagerCap { id } = cap;
        id.delete();
    }
}
