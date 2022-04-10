// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Token} from "../interfaces/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Platform is Ownable {

    mapping (string => AggregatorV3Interface) internal assetAggregator;

    Token private scopeToken;
    mapping(string => address) private stakersToken;
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

    mapping (string => address) public assetAddress;

    mapping(string => uint256) public assetRewards;

    address[] public assets;


    struct StakerInfor{
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
        assetAddress[name_] = address_;
        assets.push(address_);
    }

    function getNumberOfAssets() public view returns (uint256) {
        return assets.length;
    }
    function addStakeToken(string memory asset_, address token_) external {
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

    function getTotalMintable(string memory asset_, uint256 scopes) public view returns (uint) {
        require(scopes >= 99 ether, "low scopes");
        int price = getLatestPrice(asset_);
        return scopes/uint(price);

    }

    modifier onlyAssets(string memory asset_) {
        require(msg.sender == assetAddress[asset_]);
        _;
    }
    //checks if the buyer already has the asset
    function checkBuyerExists(address buyer, string memory asset_) private view returns(bool) {
        return assetAddress[asset_].balanceOf(buyer) > 0;
    }
    function buyAsset(
        string memory assetName_,
        uint256 amount_,
        address sender_
    ) external onlyAssets(assetName_) returns (uint256 assetMintable){
        require(
            amount_ >= 100 ether,
            "amount low"
        );
        require(
            scopeToken.allowance(sender_, address(this)) >= amount_, 
            "give allowance"
        );
        require(
            getAssetRatio(assetName_) >= 3,
            "current ratio < 0"
        );
        uint256 transaction = (amount_ * 99)/100;
        uint256 amount = amount_ - transaction;
        scopeToken.transferFrom(sender_, address(this), amount_);
        assetRewards[assetName_] += transaction;
        amountDeposited[sender_][assetName_] += amount;
        assetMintable = getTotalMintable(assetName_, amount);

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
        address token = assetAddress[asset_];
        int256 currentAssetvalue = currentPrice * int256(Token(token).totalSupply());
        int256 change = ((int256(startAssetValue) - currentAssetvalue) * 100) / int256(startAssetValue);
        return (
            (addressAssetTotalStaked[staker][asset_].amount * uint256(change))/100
        );


    }

    function checkOut(
        string memory asset_,
        uint256 amount_,
        address sender_
    ) external onlyAssets(asset_) {
        address token = assetAddress[asset_];
        require(
            Token(token).balanceOf(sender_) >= amount_,
            "amount"
        );
        Token(token).transferFrom(
            sender_,
            address(this),
            amount_
        );
        uint mints = uint256(getLatestPrice(asset_)) * amount_;
        scopeToken.transfer(sender_, mints);
        uint256 amountde = amountDeposited[sender_][asset_];

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
        address token = assetAddress[name_];
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
            totalAmount,
            getLatestPrice(name_),
            assetTotalStaked[name_],
            (Token(token).totalSupply() * uint256(getLatestPrice(name_)))
        );
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
        uint transaction = (amount * 99)/100;
        uint burnables = amount - transaction;
        uint scopes = (uint256(getLatestPrice(asset_)) * burnables);
        addressAssetTotalStaked[msg.sender][asset_].amount -= amount;
        scopeToken.transfer(msg.sender, scopes);
    }

    modifier onlyStaker(string memory asset_) {
        require( msg.sender == stakersToken[asset_]);
        _;
    }
    function claimRewards(
        string memory asset_,
        address sender
    ) external onlyStaker(asset_) updateReturns(asset_, msg.sender) returns(uint256 reward){
        reward = rewards[msg.sender][asset_];
        rewards[msg.sender][asset_] = 0;
    }

/*
    This function burns the asset's stake token rewards
    and reduces the its backing by the ration of the asset burned to its totalSupply
*/
    function exchangeStakeToken(
        string memory asset_,
        uint256 amount_,
        address sender
    ) external onlyStaker(asset_) {
        address token = stakersToken[asset_];
        //require(
        //    Token(token).allowance(sender, address(this)) >= amount_,
        //    "allowance"
        //);
        uint256 totalTransactions = assetRewards[asset_];
        uint256 rewardTokenSupply = Token(token).totalSupply();
        uint256 amountTransferable = ((totalTransactions * amount_)/rewardTokenSupply); 
        //Token(token).burn(msg.sender, amount_);
        assetRewards[asset_] -= amountTransferable;
        scopeToken.transfer(sender, amountTransferable);
    }

    function getAssetRatio(string memory asset_) public view returns (int256) {
        address token = stakersToken[asset_];
        int256 assetValue = (
            int256(Token(token).totalSupply()) * getLatestPrice(asset_)
        );

        int256 totalStake = int256(assetTotalStaked[asset_]);
        return totalStake/assetValue;
    }
}