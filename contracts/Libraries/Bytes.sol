// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Bytes {


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

    function encodeDataURI(string memory _name, string memory _image, uint256 _level, uint256 _experience, string memory _tp, string memory _description, string memory _attack1, string memory _attack2, string memory _attack3, string memory _attack4 ) public pure returns (bytes memory){
        return abi.encodePacked(_name, _image, _level, _experience, _tp, _description, _attack1, _attack2, _attack3, _attack4);
    }

    function decodeDataURI(bytes memory _data) public pure returns(DataURI memory) {
        DataURI memory dataUri = abi.decode(_data, (DataURI));
        return dataUri;
    }

    
}