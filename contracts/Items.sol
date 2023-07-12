// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {MathInt} from "./libraries/MathInt.sol";

contract Items is ERC1155, Ownable, ERC1155Burnable {

    // MWG Token Contract
    ERC20 mwgContract;

    // USDC Token Contract
    ERC20 usdcContract;

    // Address to return the MWG
    address public usedMWG;

    // Address to transfer the USDC when the starterPack is bought
    address mintWorld;

    string _uri;

    mapping(uint256 => uint256) prices;

    // Starter Pack price USDC (No use wei)
    uint256 public starterPackPrice;

    //Active tokens Ids
    mapping(uint256 => bool) tokenIds;

    constructor(address _mwgContract, address _usdcContract, uint256 _starterPackPrice, address _mintWorld) ERC1155("") {
        mwgContract = ERC20(_mwgContract);
        usdcContract = ERC20(_usdcContract);
        starterPackPrice = _starterPackPrice;
        mintWorld = _mintWorld;
    }

    //----- SET FUNCTIONS -----//

    function setURI(string memory newuri) public onlyOwner {
        _uri = newuri;
    }

    function setPrices(uint256 tokenId, uint256 price) public onlyOwner{
        prices[tokenId] = price;
    }

    function setusedMWG(address _usedMWG) public onlyOwner{
        usedMWG = _usedMWG;
    }

    function setTokenIds(uint256 id, bool val) public onlyOwner{
        tokenIds[id] = val;
    }

    function setNewUsdcContract(address _usdcContract) public onlyOwner{
        usdcContract = ERC20(_usdcContract);
    }

    function setNewMwgContract(address _mwgContract) public onlyOwner{
        mwgContract = ERC20(_mwgContract);
    }

    function setStarterPackPrice(uint256 _starterPackPrice) public onlyOwner{
        starterPackPrice = _starterPackPrice;
    }

    function serMintWorldWallet(address _mintWorld) public onlyOwner{
        mintWorld = _mintWorld;
    }

    //----- END -----//

    //----- MINT AND BURN -----//

    //Call increaseAllowance function of MWGContract(spender this contract and amount valueMWG)
    function mint(uint256 id, uint256 amount, uint256 valueMWG)
        public
    {
        require(tokenIds[id], "TokenId no active");
        require(mwgContract.balanceOf(msg.sender) >= MathInt.mul(valueMWG, 10**uint256(mwgContract.decimals())), "Not enough MWG");
        require(valueMWG >= prices[id]*amount, "Not enough MWG sent");
        
        // Transfer MWG tokens from the sender to usedMWG address
        require(
        mwgContract.transferFrom(
            msg.sender,
            usedMWG,
            MathInt.mul(valueMWG, 10**uint256(mwgContract.decimals()))
        ),
            "Failed to transfer MWG tokens"
        );

        _mint(msg.sender, id, amount, "");
    }

    function mintAndBurn(uint256 id, uint256 amount, uint256 valueMWG, uint256 amountToBurn) public 
    {
        require(tokenIds[id], "TokenId no active");
        require(mwgContract.balanceOf(msg.sender) >= MathInt.mul(valueMWG, 10**uint256(mwgContract.decimals())), "Not enough MWG");
        require(valueMWG >= prices[id]*amount, "Not enough MWG sent");
    
        // Transfer MWG tokens from the sender to usedMWG address
        require(
        mwgContract.transferFrom(
            msg.sender,
            usedMWG,
            MathInt.mul(valueMWG, 10**uint256(mwgContract.decimals()))
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

    //----- END -----//

    //----- STARTER PACK -----//

    //Call increaseAllowance function of UsdcContract(spender this contract and amount starterPack Price)
    function StarterPack() public {
        require(usdcContract.balanceOf(msg.sender) >= MathInt.mul(starterPackPrice, 10**uint256(usdcContract.decimals())), "Not enough USDC");

        // Transfer USDC tokens from the sender to MintWorld address
        require(
            usdcContract.transferFrom(
                msg.sender,
                mintWorld,
                MathInt.mul(starterPackPrice, 10**uint256(usdcContract.decimals()))
            ),
            "Failed to transfer USDC tokens"
        );

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 1;
        amounts[1] = 5;

        _mintBatch(msg.sender, ids, amounts, "");
    }

    //----- END -----//

    //----- VIEW INFO FUNCTIONS -----//

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory token = Strings.toString(tokenId);
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, token, ".json")) : "";
    }

    //----- END -----//

    // Function to receive Matic. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

}