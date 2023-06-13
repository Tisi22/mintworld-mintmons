//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MintmonsUriStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";


contract BaseMintmons is MintmonsUriStorage, ERC2981, Ownable {

    uint256 _tokenId;
    bool public mintState;

    // A map of addresses that are authorised to mint and update metadata.
    mapping(address => bool) public controllers;


    event MintmonMetadataUpdate(uint256 indexed _tokenId);
    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);

    constructor() ERC721("Mintmon", "MTM") {
      _tokenId = 1;
      mintState = true;
    }

    /**
     * @dev Mints and NFT
     */
    function mint(address to, bytes calldata data) external{
        require(controllers[msg.sender], "Not authorized");
        require(mintState, "Minting is paused");
        _tokenId ++;
        _safeMint(to, _tokenId-1);
        _setTokenURI(_tokenId-1, data);
    }

    /**
     * @dev updates the metadata of a NFT
     */
    function _metadataUpdateParty(uint256 tokenID, bytes calldata data) external {
        require(controllers[msg.sender], "Not authorized");
        _setTokenURI(tokenID, data);

        emit MintmonMetadataUpdate(tokenID);
    }

    //----- VIEW INFO FUNCTIONS -----//
    
    /**
     * @dev Returns all the tokenIds of a wallet
     */
    function walletOfOwner(address _owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= totalSupply()) {
        address currentTokenOwner = ownerOf(currentTokenId);

        if (currentTokenOwner == _owner) {
            ownedTokenIds[ownedTokenIndex] = currentTokenId;

            ownedTokenIndex++;
        }

        currentTokenId++;
        }

        return ownedTokenIds;
    }

    /**
     * @dev Total minted supply
     */
    function totalSupply() public view returns (uint256){
        return _tokenId-1;
    }

    //----- END -----//

    //----- SET FUNCTIONS -----//

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator, if it is 1000 -> 10%.
     */
    function setFeeNum(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev Sets mint state
     */
    function setMintState(bool _mintState) public onlyOwner {
        mintState = _mintState;
    }

    /**
    * @dev Authorises a controller.
    */
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    /**
    * @dev Revoke controller permission for an address
    */
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    //----- END -----//

    //----- OVERRIDE FUNCTIONS -----//

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //----- END -----//

    // Function to receive Canto. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    
}
