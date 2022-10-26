

module TokenAddress::suntoken {
    use aptos_framework::coin;
    use std::string;
    use std::signer;
    use aptos_framework::coin::{BurnCapability, MintCapability, FreezeCapability, mint, deposit, Coin, burn, transfer, balance, is_account_registered, withdraw};

    struct SunhonxCoin {}

    struct CoinCapabilities<phantom SunhonxCoin> has key {
        mint_cap: MintCapability<SunhonxCoin>,
        burn_cap: BurnCapability<SunhonxCoin>,
        freeze_cap: FreezeCapability<SunhonxCoin>,
    }

    public entry fun init_token(account: &signer) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<SunhonxCoin>(
            account,
            string::utf8(b"Sunhonx Test Token"),
            string::utf8(b"SunT"),
            8,
            true,

        );
        assert!(signer::address_of(account) == @TokenAddress, 1);
        assert!(!exists<CoinCapabilities<SunhonxCoin>>(@TokenAddress), 2);
        move_to<CoinCapabilities<SunhonxCoin>>(account, CoinCapabilities<SunhonxCoin>{mint_cap, burn_cap, freeze_cap})

    }

    public entry fun mint_token<SunhonxCoin>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);

        assert!(account_address == @TokenAddress, 1);
        assert!(exists<CoinCapabilities<SunhonxCoin>>(account_address), 2);

        let mint_cap = &borrow_global<CoinCapabilities<SunhonxCoin>>(account_address).mint_cap;
        let coin = mint<SunhonxCoin>(amount, mint_cap);

        deposit<SunhonxCoin>(user, coin)
    }

    public entry fun burn_token<SunhonxCoin>(coins: Coin<SunhonxCoin>) acquires CoinCapabilities {
        let burn_cap = &borrow_global<CoinCapabilities<SunhonxCoin>>(@TokenAddress).burn_cap;

        burn<SunhonxCoin>(coins, burn_cap)
    }

    public entry fun transfer_token<SunhonxCoin>(from: &signer, to: address, amount: u64) {
        let from_address = signer::address_of(from);


        assert!(is_account_registered<SunhonxCoin>(to), 0);

        assert!(balance<SunhonxCoin>(from_address) > amount, 1);
        transfer<SunhonxCoin>(from, to, amount)
    }

    public entry fun withraw_token<SunhonxCoin>(account: &signer, amount: u64) acquires CoinCapabilities {
        let address = signer::address_of(account);
        assert!(balance<SunhonxCoin>(address) > amount, 0);
        let coin = withdraw<SunhonxCoin>(account, amount);
        let burn_cap = &borrow_global<CoinCapabilities<SunhonxCoin>>(@TokenAddress).burn_cap;
        burn(coin, burn_cap)
    }




}