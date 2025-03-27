module ScholarshipModule::Scholarship {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a scholarship
    struct Scholarship has store, key {
        total_funds: u64,          // Total funds in the scholarship
        max_recipients: u64,        // Maximum number of scholarship recipients
        distributed_count: u64,     // Number of recipients who have received funds
        scholarship_amount: u64,    // Amount per scholarship recipient
    }

    /// Function to create a new scholarship
    public fun create_scholarship(
        admin: &signer, 
        total_scholarship_budget: u64, 
        max_recipients: u64
    ) {
        let scholarship = Scholarship {
            total_funds: total_scholarship_budget,
            max_recipients,
            distributed_count: 0,
            scholarship_amount: total_scholarship_budget / max_recipients
        };
        move_to(admin, scholarship);
    }

    /// Function to distribute scholarship to a recipient
    public fun distribute_scholarship(
        admin: &signer, 
        recipient: address
    ) acquires Scholarship {
        let scholarship = borrow_global_mut<Scholarship>(signer::address_of(admin));
        
        // Check if scholarship can be distributed
        assert!(scholarship.distributed_count < scholarship.max_recipients, 1);
        
        // Transfer scholarship amount to recipient
        let scholarship_fund = coin::withdraw<AptosCoin>(admin, scholarship.scholarship_amount);
        coin::deposit<AptosCoin>(recipient, scholarship_fund);
        
        // Update distribution count
        scholarship.distributed_count = scholarship.distributed_count + 1;
    }
}