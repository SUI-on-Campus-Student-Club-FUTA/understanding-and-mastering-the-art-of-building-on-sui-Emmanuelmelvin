module workshop_project::manager {
    public struct BankManagerCap has key, store {
        id: UID
    }

    public(package) fun create(
        ctx: &mut TxContext
    ):BankManagerCap{
        BankManagerCap{
            id: object::new(ctx)
        }
    }


    public fun create_and_transfer(
        _: &BankManagerCap,
        address: address,
        ctx: &mut TxContext
    ){
        transfer::public_transfer(
        BankManagerCap{
            id: object::new(ctx)
        },
        address
        )
    }

    public fun transfer(
        cap: BankManagerCap,
        address: address,
    ){
        transfer::public_transfer(
            cap,
            address
        )
    }

    public fun delete(
        cap: BankManagerCap
    ){
        let BankManagerCap { id } = cap;
        id.delete();
    }
}
