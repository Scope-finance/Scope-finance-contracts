// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Token} from "../interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Thetix is Ownable {

    mapping (string => AggregatorV3Interface) internal assetAggregator;

    Token private stakersToken;
    Token private scopeToken;
    address private factory;

    // array for current stakers peer asset
    mapping(string => address[]) private stakers;

    // a mapping of all buyers of an asset
    mapping(string => address[]) private buyers;


    mapping (string => Token) public assetAddress;

    mapping (string => int256) private _assetPrice;

    struct StakerInfor{
        bool active;
        uint256 initialAmount;
        int256 startPrice;
    }

    mapping (address => mapping(string => StakerInfor)) public addressAssetTotalStaked;

    event AssetBought(string indexed name_, address buyer);

    event Assetbacked(string indexed name_, address staker);

    
    constructor(
        Token sopeToken_,
        Token stakersToken_,
        address factory_ //asset factory address
    ) {
        scopeToken = sopeToken_;//ScopeToken addressSS
        stakersToken  = stakersToken_;
        factory = factory_;
    }

    
    //Adds a new asset to the platform
    function addAsset(
        string memory name_,
        Token address_
    ) external {
        require(
            msg.sender == factory,
            "only factory"
        );
        assetAddress[name_] = address_;
    }


    //adds the asset's aggregator
    function addAssetAggregator(
        string memory name_,
        AggregatorV3Interface agg_
    ) external onlyOwner {
        assetAggregator[name_] = agg_;    
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
        scopeToken.burn(msg.sender, amount_);
        uint assetMintable = (getTotalMintable(assetName_, amount_) * 1000000000000000000);
        assetAddress[assetName_].mint(msg.sender, assetMintable);

    } 

    function getLatestPrice(string memory asset_) public view returns (int) {
        (,int price,,,) = assetAggregator[asset_].latestRoundData();
        return price;
    }

    function getStakerBalance(
        address staker,
        string memory asset_
    ) public view returns(uint256) {
        int256 currentPrice = getLatestPrice(asset_);
        int256 startPrice = addressAssetTotalStaked[msg.sender][asset_].startPrice;

    }


    function getSopesMintable(uint256 assetAmount) private view returns (uint256) {

    }
    function checkOut(string memory asset_, uint256 amount_) external {
        require(assetAddress[asset_].balanceOf(msg.sender) != 0);
        assetAddress[asset_].burn(msg.sender, amount_);
        scopeToken.mint(msg.sender, amount_); //amount should be computed

    }

    //checks if an address is an active staker on the asset
    function checkIfexists(
        address staker,
        string memory assetName_) private view returns (bool) {
        return addressAssetTotalStaked[staker][assetName_].active;
    }
    function stakeonAsset(string memory name_, uint256 scopes) external {
        require(scopes >= 100000000000000000000);
        require(scopeToken.allowance(staker, address(this)) >= scopes);
        scopeToken.burn(msg.sender, scopes);
        stakersToken.mint(msg.sender, (scopes/3));
        /*
        if (checkIfexists(msg.sender, name_) == true) {

        }
        else {
            addressAssetTotalStaked[msg.sender][name_] = StakerInfor(
                true,
                scopes,
                getLatestPrice(name_)
            );
        }

    */
    }

    
}