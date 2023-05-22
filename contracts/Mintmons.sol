//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;
pragma abicoder v2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import {BaseMintmons} from "./BaseNFTs/BaseMintmons.sol";


contract Mintmons is EIP712, AccessControl, Ownable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "Mintmon-Voucher";
    string private constant SIGNATURE_VERSION = "1";


    mapping(address => bool) public mintedFirstMintmon;

    BaseMintmons base;

    struct NFTVoucher {
    uint256 tokenId;
    string image;
    bytes32[7] data;
    uint256[2] stats;
    bytes signature;
    }


    constructor(address minter, BaseMintmons _base) 
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        _setupRole(MINTER_ROLE, minter);
            base = _base;
    }

    function redeemFirstMintmon(address redeemer, NFTVoucher calldata voucher) public {
        require(!mintedFirstMintmon[msg.sender], "already minted");
        // make sure signature is valid and get the address of the signer
        address signer = _verify(voucher);

        // make sure that the signer is authorized to mint NFTs
        require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

        mintedFirstMintmon[msg.sender] = true;

        bytes memory data = _encodeDataURI(voucher);

        base.mint(redeemer, data);
    }


    /// @notice Redeems an NFTVoucher for an actual NFT, creating it in the process.
    /// @param redeemer The address of the account which will receive the NFT upon success.
    /// @param voucherArray A signed NFTVoucher that describes the NFT to be redeemed.
    function redeem(address redeemer, NFTVoucher[] calldata voucherArray) public {

        for (uint i = 0; i < voucherArray.length; i++) {

            // make sure signature is valid and get the address of the signer
            address signer = _verify(voucherArray[i]);

            // make sure that the signer is authorized to mint NFTs
            require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

            bytes memory data = _encodeDataURI(voucherArray[i]);
            base.mint(redeemer, data);

        }  
    }

    function metadataUpdateParty(NFTVoucher[] calldata voucherArray) public {

        for (uint i = 0; i < voucherArray.length; i++) {

            
            // make sure signature is valid and get the address of the signer
            address signer = _verify(voucherArray[i]);

            // make sure that the signer is authorized to mint NFTs
            require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

            bytes memory data = _encodeDataURI(voucherArray[i]);

            base._metadataUpdateParty(voucherArray[i].tokenId, data);

        }

    }

    function _hash(NFTVoucher calldata voucher) internal view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("NFTVoucher(uint256 tokenId,string image,bytes32[7] data,uint256[2] stats)"),
        voucher.tokenId,
        keccak256(bytes(voucher.image)),
        keccak256(abi.encodePacked(voucher.data)),
        keccak256(abi.encodePacked(voucher.stats))
    )));
    }

    /// @notice Returns the chain id of the current blockchain.
    /// @dev This is used to workaround an issue with ganache returning different values from the on-chain chainid() function and
    ///  the eth_chainId RPC method. See https://github.com/protocol/nft-website/issues/121 for context.
    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /// @notice Verifies the signature for a given NFTVoucher, returning the address of the signer.
    /// @dev Will revert if the signature is invalid. Does not verify that the signer is authorized to mint NFTs.
    /// @param voucher An NFTVoucher describing an unminted NFT.
    function _verify(NFTVoucher calldata voucher) public view returns (address) {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }

    function checkMintedFirstMintmon(address adr) public view returns(bool){
        return mintedFirstMintmon[adr];
    }

    function setMintedFirstMintmon(address adr, bool val) public onlyOwner{
        mintedFirstMintmon[adr] = val;
    }

    function _encodeDataURI(NFTVoucher calldata voucher) internal pure returns (bytes memory) {
    return abi.encode(voucher.image, voucher.data, voucher.stats);
    }

}
