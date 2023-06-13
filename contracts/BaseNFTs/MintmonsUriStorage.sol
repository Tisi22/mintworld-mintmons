// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract MintmonsUriStorage is ERC721 {

    mapping (uint256 => bytes) mintmonsURI;

    //data: Name, type, attack1, attack2, attack3, attcak4
    //stats: level, experience

    struct DataURI{
        string image;
        string description;
        bytes32[6] data;
        uint256[2] stats;
    }

    constructor(){
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        bytes memory _data = mintmonsURI[tokenId];

        DataURI memory data_ = _decodeDataURI(_data);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                    '{"name": "', bytes32ToString(data_.data[0]),
                    '","description":"',data_.description, 
                    '", "image": "', data_.image,
                    '", "tokenId": "', Strings.toString(tokenId),
                    '","attributes": [ { "trait_type": "Type", "value": "',
                    bytes32ToString(data_.data[1]),
                    '"}, { "trait_type": "Attack_1", "value": "',
                    bytes32ToString(data_.data[2]),                
                    '"}, { "trait_type": "Attack_2", "value": "',
                    bytes32ToString(data_.data[3]),                
                    '"}, { "trait_type": "Attack_3", "value": "',
                    bytes32ToString(data_.data[4]),                
                    '"}, { "trait_type": "Attack_4", "value": "',
                    bytes32ToString(data_.data[5]),
                    '"}, { "trait_type": "Level", "value": "',
                    Strings.toString(data_.stats[0]),
                    '"}, { "trait_type": "EXP", "value": "',
                    Strings.toString(data_.stats[1]),                
                    '"} ]}'
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

    function _decodeDataURI(bytes memory encodedData) internal pure returns (DataURI memory) {
        string memory image;
        string memory description;
        bytes32[6] memory data;
        uint256[2] memory stats;

        // Decode the data URI components
        (image, description, data, stats) = abi.decode(encodedData, (string, string, bytes32[6], uint256[2]));


        // Create and return the DataURI struct
        return DataURI(image, description, data, stats);
    }


    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
 
}