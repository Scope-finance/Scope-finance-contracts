// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Token} from "../interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Platform is Ownable {

    mapping (string => AggregatorV3Interface) internal assetAggregator;

    Token private scopeToken;
    mapping(string => Token) private stakersToken;
    address private factory;
    address private stakefactory;

    //number of tokents minted per second for every asset
    mapping (string => uint256) private rateOfReward;

    mapping (string => uint256) private lastUpdate;

    mapping (string => uint256) private rewardpertoken;

    mapping (address => mapping(string => uint256)) public userRewardPerAsset;

    mapping(address => mapping(string => uint256)) public rewards;

    mapping (string => uint256) private assetTotalStaked;

    mapping (address => mapping(string => StakerInfor)) public addressAssetTotalStaked;

    mapping (address => mapping(string => uint256)) public amountDeposited;

    mapping(string => uint256) private assetAvailableAmount;

    mapping (string => Token) public assetAddress;

    mapping(string => uint256) public assetRewards;

    struct StakerInfor{
        bool active;
        uint256 amount;
        int256 startPrice;
        uint256 startStake;//the balance of staked tokens
        uint256 startAssetValue; //the  total value of the asset in circulation
    }

    event AssetBought(string indexed name_, address buyer);

    event Assetbacked(string indexed name_, address staker);

    constructor(
        address sopeToken_,
        address factory_, //asset factory address
        address stakefactory_
    ) {
        scopeToken = Token(sopeToken_);//ScopeToken addressSS
        factory = factory_;
        stakefactory =stakefactory_;
    }

    modifier updateRatio(string memory name) {
        _;
    }
    
    //Adds a new asset to the platform
    function addAsset(
        string memory name_,
        address address_
    ) external {
        require(
            msg.sender == factory,
            "only factory"
        );
        assetAddress[name_] = Token((address_));
    }

    function addStakeToken(string memory asset_, Token token_) external {
        require(
            msg.sender == stakefactory,
            "only factory"
        );
        stakersToken[asset_] = token_;
    }

    //adds the asset's aggregator
    function addAssetAggregator(
        string memory name_,
        address agg_
    ) external onlyOwner {
        assetAggregator[name_] = AggregatorV3Interface(agg_);    
    }

    function getTotalMintable(string memory asset_, uint256 scopes) private view returns (uint) {
        require(scopes >= 100 ether, "low sopes");
        int price = getLatestPrice(asset_);
        return scopes/uint(price);

    }

    //checks if the buyer already has the asset
    function checkBuyerExists(address buyer, string memory asset_) private view returns(bool) {
        return assetAddress[asset_].balanceOf(buyer) > 0;
    }
    function buyAsset(
        string memory assetName_,
        uint256 amount_
    ) external {
        require(scopeToken.allowance(msg.sender, address(this)) >= amount_);
        require(getAssetRatio(assetName_) >= 3);
        uint256 transaction = (amount_ * 99)/100;
        uint256 amount = amount_ - transaction;
        scopeToken.transferFrom(msg.sender, address(this), amount_);

        uint assetMintable = (
            getTotalMintable(assetName_, amount)
        );
        assetAddress[assetName_].mint(msg.sender, assetMintable);
        assetRewards[assetName_] += transaction;
        amountDeposited[msg.sender][assetName_] += amount;

    } 

    function getLatestPrice(string memory asset_) public view returns (int) {
        (,int price,,,) = assetAggregator[asset_].latestRoundData();
        return price;
    }

    function getStakerBalance(
        address staker,
        string memory asset_
    ) public view returns(uint256) {
        //int256 startPrice = addressAssetTotalStaked[msg.sender][asset_].startPrice;
        //uint256 startFloat = addressAssetTotalStaked[staker][asset_].startStake;
        uint256 startAssetValue = addressAssetTotalStaked[staker][asset_].startAssetValue;
        int256 currentPrice = getLatestPrice(asset_);
        //uint256 currentFloat = assetTotalStaked[asset_];
        int256 currentAssetvalue = currentPrice * int256(assetAddress[asset_].totalSupply());
        int256 change = ((int256(startAssetValue) - currentAssetvalue) * 100) / int256(startAssetValue);
        return (
            (addressAssetTotalStaked[staker][asset_].amount * uint256(change))/100
        );


    }

    function checkOut(string memory asset_, uint256 amount_) external {
        require(assetAddress[asset_].balanceOf(msg.sender) >= amount_);
        assetAddress[asset_].transferFrom(
            msg.sender,
            address(this),
            amount_
        );
        uint mints = uint256(getLatestPrice(asset_)) * amount_;
        scopeToken.transfer(msg.sender, mints);
        uint256 amountde = amountDeposited[msg.sender][asset_];

        if (amountde < mints) {
            uint256 stakeEaten = mints - amountde;
            assetTotalStaked[asset_] -= stakeEaten;
        } else {
            uint256 growth = mints - amountde;
            assetTotalStaked[asset_] += growth;
        }
        

    }

    function earnings(
        string memory asset_,
        address staker
    ) private view returns( uint256){
        return (
            addressAssetTotalStaked[staker][asset_].amount * (
                assetReward(asset_) - userRewardPerAsset[staker][asset_]
            ) / 1e18
        ) + rewards[staker][asset_] ;
    }

    function assetReward(string memory asset_) private view returns(uint256) {
        if (assetTotalStaked[asset_] == 0) {
            return 0;
        }
        return (
            rewardpertoken[asset_] + (

                rateOfReward[asset_] * (
                    (
                        block.timestamp - lastUpdate[asset_] 
                    ) * 1e18
                ) / assetTotalStaked[asset_]
            )
        );
    }

    modifier updateReturns(
        string memory asset_,
        address staker_
    ) {
        rewardpertoken[asset_] = assetReward(asset_);
        lastUpdate[asset_] = block.timestamp;
        rewards[staker_][asset_] = earnings(asset_, staker_);
        userRewardPerAsset[staker_][asset_] = rewardpertoken[asset_];
        _;
    }


    function stakeOnAsset(
        string memory name_,
        uint256 scopes
    ) external updateReturns(name_, msg.sender) {
        require(scopes >= 100000000000000000000);
        require(
            scopeToken.allowance(msg.sender, address(this)) >= scopes
        );
        scopeToken.transferFrom(
            msg.sender,
            address(this),
            scopes
        );
        uint totalAmount = addressAssetTotalStaked[msg.sender][name_].amount + scopes;
        assetTotalStaked[name_] += scopes;
        addressAssetTotalStaked[msg.sender][name_] = StakerInfor(
            true,
            totalAmount,
            getLatestPrice(name_),
            assetTotalStaked[name_],
            (assetAddress[name_].totalSupply() * uint256(getLatestPrice(name_)))
        );
        stakersToken[name_].mint(msg.sender, (scopes/3));
    }


    function unstake(
        string memory asset_,
        uint256 amount
    ) external updateReturns(asset_, msg.sender) {
        require(
            getStakerBalance(
                msg.sender,
                asset_
            ) >= amount
        );
        uint amount_ = (amount * 3);
        uint transaction = (amount_ * 99)/100;
        uint burnables = amount_ - transaction;
        stakersToken[asset_].burn(msg.sender, burnables);
        uint scopes = (uint256(getLatestPrice(asset_)) * burnables);
        scopeToken.transfer(msg.sender, scopes);
    }

    function claimRewards(string memory asset_) external updateReturns(asset_, msg.sender) {
        uint256 reward = rewards[msg.sender][asset_];
        rewards[msg.sender][asset_] = 0;
        stakersToken[asset_].mint(msg.sender, reward);
    }

    function exchangeStakeToken(
        string memory asset_,
        uint256 amount_
    ) public {
        require(stakersToken[asset_].allowance(msg.sender, address(this)) >= amount_);
        uint256 totalTransactions = assetRewards[asset_];
        uint256 rewardTokenSupply = stakersToken[asset_].totalSupply();
        uint256 amountTransferable = ((totalTransactions * amount_)/rewardTokenSupply); 
        stakersToken[asset_].burn(msg.sender, amount_);
        assetRewards[asset_] -= amountTransferable;
        scopeToken.transfer(msg.sender, amountTransferable);
    }

    function getAssetRatio(string memory asset_) public view returns (int256) {
        int256 assetValue = (
            int256(stakersToken[asset_].totalSupply()) * getLatestPrice(asset_)
        );

        int256 totalStake = int256(assetTotalStaked[asset_]);
        return totalStake/assetValue;
    }
}