// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract MintmonsUriStorage is ERC721 {

    mapping (uint256 => bytes) mintmonsURI;

    //data: Name, description, type, attack1, attack2, attack3, attcak4
    //stats: level, experience

    struct DataURI{
        string image;
        bytes32[7] data;
        uint256[2] stats;
    }

    constructor(){
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        bytes memory _data = mintmonsURI[tokenId];

        DataURI memory data_ = decodeDataURI(_data);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', data_.data[0],
                        '","description":"',data_.data[1], 
                        '", "image": "', data_.image,
                        '", "level": "', Strings.toString(data_.stats[0]),
                        '", "experience": "', Strings.toString(data_.stats[1]),
                        '", "tokenId": "', Strings.toString(tokenId),
                        '","attributes": [ { "trait_type": "Type", "value": "',
                        data_.data[2],
                        '"}, { "trait_type": "Attack_1", "value": ',
                        data_.data[3],
                        '"}, { "trait_type": "Attack_2", "value": ',
                        data_.data[4],
                        '"}, { "trait_type": "Attack_3", "value": ',
                        data_.data[5],
                        '"}, { "trait_type": "Attack_4", "value": ',
                        data_.data[6],
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

    function _setTokenURI(uint256 tokenId, bytes memory _data) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");

        mintmonsURI[tokenId] = _data;
    }

    function _updateMetadata(uint256 tokenId, bytes memory _data) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");

        mintmonsURI[tokenId] = _data;
    }

    function decodeDataURI(bytes memory _data) public pure returns(DataURI memory) {
        DataURI memory dataUri = abi.decode(_data, (DataURI));
        return dataUri;
    }
 
}