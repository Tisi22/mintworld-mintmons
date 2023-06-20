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

contract MyToken is ERC1155, Ownable, ERC1155Burnable {

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

        mwgContract.transferFrom(msg.sender, usedMWG ,Math.mul(valueMWG, uint256(10)**mwgContract.decimals()));
        _mint(msg.sender, id, amount, "");
    }

}