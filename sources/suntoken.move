

module TokenAddress::suntoken {
    use aptos_framework::coin;
    use std::string;
    use std::signer;
    use aptos_framework::coin::{BurnCapability, MintCapability, FreezeCapability, mint, deposit, Coin, burn, transfer, balance, is_account_registered, withdraw, register};

    struct SunhonxCoin {}

    const ERR_NOT_ADMIN: u64 = 1;
    const ERR_COIN_NOT_EXIST: u64 = 2;
    const ERR_ACCOUNT_NOT_REGISTERED: u64 = 3;
    const ERR_LACK_OF_BALANCE: u64 = 4;
    const ERR_ACCOUNT_ALREADY_REGISTERED: u64 = 5;


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
        assert!(signer::address_of(account) == @TokenAddress, ERR_NOT_ADMIN);
        assert!(!exists<CoinCapabilities<SunhonxCoin>>(@TokenAddress), ERR_COIN_NOT_EXIST);
        move_to<CoinCapabilities<SunhonxCoin>>(account, CoinCapabilities<SunhonxCoin>{mint_cap, burn_cap, freeze_cap})

    }

    public entry fun mint_token<SunhonxCoin>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);

        assert!(account_address == @TokenAddress, ERR_NOT_ADMIN);
        assert!(exists<CoinCapabilities<SunhonxCoin>>(account_address), ERR_COIN_NOT_EXIST);

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


        assert!(is_account_registered<SunhonxCoin>(to), ERR_ACCOUNT_NOT_REGISTERED);

        assert!(balance<SunhonxCoin>(from_address) > amount, ERR_LACK_OF_BALANCE);
        transfer<SunhonxCoin>(from, to, amount)
    }

    public entry fun withraw_token<SunhonxCoin>(account: &signer, amount: u64) acquires CoinCapabilities {
        let address = signer::address_of(account);
        assert!(balance<SunhonxCoin>(address) > amount, ERR_LACK_OF_BALANCE);
        let coin = withdraw<SunhonxCoin>(account, amount);
        let burn_cap = &borrow_global<CoinCapabilities<SunhonxCoin>>(@TokenAddress).burn_cap;
        burn(coin, burn_cap)
    }

    public entry fun register_token<SunhonxCoin>(account: &signer) {
        let account_address = signer::address_of(account);
        assert!(!is_account_registered<SunhonxCoin>(account_address), ERR_ACCOUNT_ALREADY_REGISTERED);
        register<SunhonxCoin>(account)
    }


}