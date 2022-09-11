use crate::investment_pool::*;
use scrypto::prelude::*;

blueprint! {
   /// TODO
    struct RadHedge {
        /// This hashmap maps the pool symbol to the corresponding InvestmentPool.
        /// The InvestmentPool is a scrypto component that was instantiated earlier by the RadHedge.
        /// This hashmap is necessary to know in which InvestmentPool the investors want to invest.
        symbol_pool_mapping: HashMap<String, InvestmentPool>,

        /// This hashmap maps the pool tracking token to the corresponding InvestmentPool.
        /// The InvestmentPool is a scrypto component that was instantiated earlier by the RadHedge.
        /// This hashmap is necessary to know which InvestmentPool needs to be called if Investors want withdraw their investment.
        tracking_token_pool_mapping: HashMap<ResourceAddress, InvestmentPool>,

        /// Stores the address of the price-oracle used for the RadHedge.
        oracle_address: ComponentAddress,

        /// Stores the address of the decentralized exchange (DEX) thats being used for this pool. For now the RadHedge is only functional with the RaDEX.
        dex_address: ComponentAddress,

        /// Address of the base currency used for the RadHedge plattform.
        base_currency: ResourceAddress,
    }


    // TODO
    // !. Registry of all investment_pools
    // 2. Mapping pool_token to pool
    //
    // Instantiate new investment_pools
    // "FrontEnd" für die Investment pools --> Durchrouten zu darunterliegenden Funktionen
    // "Delete" pools (if empty)

    impl RadHedge {
        /// Instantiates a new RadHedge component.
        ///
        /// # Arguments:
        ///
        /// * `oracle_address` (ComponentAddress) - The address of the price-oracle used for the RadHedge.
        /// * `dex_address` (ComponentAddress) - The address of the decentralized exchange (DEX) thats being used for this pool. For now the RadHedge is only functional with the RaDEX.
        ///
        /// # Returns
        ///
        /// * `Component` - A new RadHedge component.
        pub fn instantiate(
            oracle_address: ComponentAddress,
            dex_address: ComponentAddress,
            base_currency: ResourceAddress,
        ) -> ComponentAddress {
            return Self {
                symbol_pool_mapping: HashMap::new(),
                tracking_token_pool_mapping: HashMap::new(),
                oracle_address,
                dex_address,
                base_currency,
            }
            .instantiate()
            .globalize();
        }

        /// Checks if a investment pool for the given symbol exists or not.
        ///
        ///
        /// # Arguments:
        ///
        /// * `symbol` (String) - The symbol of the InvestmentPool. Please provide *exact* symbol.
        ///
        /// # Returns:
        ///
        /// * `bool` - A boolean of whether the investment pool exists for this symbol.
        pub fn pool_exists(&self, symbol: String) -> bool {
            // Check whether the symbol exists in the hashmap.
            return self.symbol_pool_mapping.contains_key(&symbol);
        }


        /// Asserts that a investment pool exists for the given symbol.
        ///
        /// # Arguments:
        ///
        /// * `symbol` (String) - The symbol of the investment pool. Please provide *exact* symbol.
        pub fn assert_pool_exists(&self, symbol: String) {
            assert!(
                self.pool_exists(symbol),
                "No investment pool exists for the given symbol: {}.",
                symbol
            );
        }

        /// Asserts that a investment pool doesn't exist for the given symbol.
        ///
        /// # Arguments:
        ///
        /// * `symbol` (String) - The symbol of the investment pool. Please provide *exact* symbol.
        pub fn assert_pool_doesnot_exist(&self, symbol: String) {
            assert!(
                !self.pool_exists(symbol),
                "An investment pool exists for the given symbol: {} already exists.",
                symbol
            );
        }

        /// Creates a new investment pool on the RadHedge platform.
        ///
        /// This is the method to call if you want to open up an investment pool on the RadHedge platform.
        /// This should be called only by actors that wan't to engage as manager of pool funds. For creation
        /// of the pool no initial funds need to be provided by the pool manager. The can afterwards be provided
        /// by calling: TODO
        ///
        /// The `symbol`you provide will be used by investors to invest in your pool. Please make sure you make a good decision
        /// how you want to name your symbol.
        ///
        /// This method checks if there is already a investment pool with the same symbol.
        /// Other checks are done on the investment level.
        ///
        /// # Arguments:
        ///
        /// * `performance_fee` (Decimal) - The performance fee as percentage (0-20). Performance fees will only accrue if high-water-mark is topped.
        /// * `pool_name` (String)   - The name of the investment pool.
        /// * `pool_symbol` (String) - The symbol of the investment pool.
        ///
        /// # Returns:
        ///
        /// * `Bucket` - A bucket containing the pool manager badge issued to the creator of the investment pool.
        pub fn new_investment_pool(&mut self,
                                    performance_fee: Decimal,
                                    pool_name: String,
                                    pool_symbol: String,) -> Bucket {

            // Checking if a investment pool already exists.
            self.assert_pool_doesnot_exist(pool_symbol);

            // Creating the investment pool.
            let (investment_pool, pool_manager_badge, pool_token_address): (ComponentAddress, Bucket, ResourceAddress) =
                InvestmentPool::instantiate_pool(performance_fee,
                    self.oracle_address,
                    self.dex_address,
                    self.base_currency,
                    pool_name,
                    pool_symbol,
                );

            // Adding the liquidity pool to the hashmap of all liquidity pools
            self.symbol_pool_mapping.insert(pool_symbol, investment_pool.into());

            // Adding the resource address of the tracking tokens to the hashmap that maps the tracking tokens with
            // the address of their token pairs
            self.tracking_token_pool_mapping.insert(pool_token_address, investment_pool.into());

            // Returning the tracking tokens back to the caller of this method (the initial liquidity provider).
            pool_manager_badge
        }

    }
}
