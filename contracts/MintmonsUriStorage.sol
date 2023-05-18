// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./Libraries/Bytes.sol";

abstract contract MintmonsUriStorage is ERC721 {

    using Bytes for bytes;

    mapping (uint256 => bytes) mintmonsURI;

    struct DataURI{
        string name;
        string image;  
        uint256 level;
        uint256 experience;
        string tp;
        string description;
        string attack1;
        string attack2;
        string attack3;
        string attack4;
    }

    struct NFTVoucher {
        uint256 tokenId;
        string name;
        uint256 level;
        uint256 experience;
        string image;
        string tp;
        string description;
        string attack1;
        string attack2;
        string attack3;
        string attack4;
        bytes signature;
    }

    constructor(){
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        bytes memory _data = mintmonsURI[tokenId];

        DataURI memory data = Bytes.decodeDataURI(_data);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', data.name,
                        '","description":"',data.description, 
                        '", "image": "', data.image,
                        '", "level": "', Strings.toString(data.level),
                        '", "experience": "', Strings.toString(data.experience),
                        '", "tokenId": "', Strings.toString(tokenId),
                        '","attributes": [ { "trait_type": "Type", "value": "',
                        data.tp,
                        '"}, { "trait_type": "Attack_1", "value": ',
                        data.attack1,
                        '"}, { "trait_type": "Attack_2", "value": ',
                        data.attack2,
                        '"}, { "trait_type": "Attack_3", "value": ',
                        data.attack3,
                        '"}, { "trait_type": "Attack_4", "value": ',
                        data.attack4,
                        "} ]}"
                    )

                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function _setTokenURI(uint256 tokenId, NFTVoucher memory voucher) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");

        bytes memory _data = Bytes.encodeDataURI(voucher.name, voucher.image, voucher.level, voucher.experience, voucher.tp,voucher.description, voucher.attack1, voucher.attack2, voucher.attack3, voucher.attack4);
        mintmonsURI[tokenId] = _data;

    }

    function _updateMetadata(NFTVoucher calldata voucher) internal virtual {
        require(_exists(voucher.tokenId), "Token ID does not exist");

        bytes memory _data = Bytes.encodeDataURI(voucher.name, voucher.image, voucher.level, voucher.experience, voucher.tp,voucher.description, voucher.attack1, voucher.attack2, voucher.attack3, voucher.attack4);
        mintmonsURI[voucher.tokenId] = _data;
    }
 
}