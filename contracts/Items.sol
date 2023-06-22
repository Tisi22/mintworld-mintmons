// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Math} from "./libraries/Math.sol";

interface MintWorldToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
}

contract Items is ERC1155, Ownable, ERC1155Burnable {

    MintWorldToken mwgContract;

    address usedMWG;

    mapping(uint256 => uint256) prices;

    constructor(address _mwgContract) ERC1155("") {
        mwgContract = MintWorldToken(_mwgContract);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setPrices(uint256 tokenId, uint256 price) public onlyOwner{
        prices[tokenId] = price;
    }

    function setusedMWG(address _usedMWG) public onlyOwner{
        usedMWG = _usedMWG;
    }


    //Call approve function of MWGContract(spender this contract and amount valueMWG)
    function mint(uint256 id, uint256 amount, uint256 valueMWG)
        public
    {
        require(mwgContract.balanceOf(msg.sender) >= valueMWG, "Not enough MWG");
        require(prices[id]*amount >= valueMWG, "Not enough MWG sent");

        // Transfer MWG tokens from the sender to usedMWG address
        require(
        mwgContract.transferFrom(
            msg.sender,
            usedMWG,
            Math.mul(valueMWG, 10**uint256(mwgContract.decimals()))
        ),
            "Failed to transfer MWG tokens"
        );

        _mint(msg.sender, id, amount, "");
    }

    function mintAndBurn(uint256 id, uint256 amount, uint256 valueMWG, uint256 amountToBurn) public 
    {
        require(mwgContract.balanceOf(msg.sender) >= valueMWG, "Not enough MWG");
        require(prices[id]*amount >= valueMWG, "Not enough MWG sent");

        // Transfer MWG tokens from the sender to usedMWG address
        require(
        mwgContract.transferFrom(
            msg.sender,
            usedMWG,
            Math.mul(valueMWG, 10**uint256(mwgContract.decimals()))
        ),
            "Failed to transfer MWG tokens"
        );

        burn(msg.sender, id, amountToBurn);

        _mint(msg.sender, id, amount, "");
    }

    function burnItems(uint256[] calldata ids, uint256[] calldata amounts) public
    {
        require(ids.length == amounts.length, "Invalid arguments");

        for (uint i = 0; i < ids.length; i++)
        {
            burn(msg.sender, ids[i], amounts[i]);
        }
        
    }

}