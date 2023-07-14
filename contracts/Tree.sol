// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Tree is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address private _seedTokenContract;

    constructor(address seedTokenContract) ERC721("Tree", "TREE") {
        _seedTokenContract = seedTokenContract;
    }

    event TreeNFTGenerated(uint256 tokenId, address indexed owner);

    function createTreeNFT(address owner) external returns (uint256) {
        require(msg.sender == _seedTokenContract, "Only the SeedToken contract can call this function.");

        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(owner, tokenId);
        _tokenIdCounter.increment();
        emit TreeNFTGenerated(tokenId, owner); 
        return tokenId;
    }
}
