// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import './Tree.sol';

contract SeedToken is ERC20 {
    using Counters for Counters.Counter;
    Counters.Counter private _dailyMintCounter;

    mapping(address => uint256) private _lastMintTimestamp;
    mapping(uint256 => mapping(uint256 => Seed)) private _seeds;
    mapping(uint256 => mapping(uint256 => bool)) private _isTree;

    uint256 private constant SECONDS_IN_A_DAY = 86400;

    event SeedPlanted(address indexed user, uint256 x, uint256 y);
    event WaterAdded(address indexed caller, uint256 x, uint256 y);
    event SeedTurnedSapling(uint256 x, uint256 y);
    event TreeGeneratedAt(uint256 x, uint256 y, address indexed user, uint256 tokenId);

    struct Seed {
        bool isPlanted;
        bool isWatered;
        uint256 lastWateredTimestamp;
        uint256 plantedTimestamp;
    }

    address private _treeContractAddress;

    constructor() ERC20("Seed", "SEED") {
        _mint(msg.sender, 1 * 10**18);
    }

    function mintSeed() external {
        require(
            _lastMintTimestamp[msg.sender] + SECONDS_IN_A_DAY <= block.timestamp,
            "You can only mint one seed token per day."
        );

        _dailyMintCounter.increment();
        require(
            _dailyMintCounter.current() <= 1,
            "The daily limit for minting seed tokens has been reached."
        );

        _mint(msg.sender, 1 * 10**18);
        _lastMintTimestamp[msg.sender] = block.timestamp;
    }

    function plantSeed(uint256 x, uint256 y) external {
        require(balanceOf(msg.sender) >= 1, "You must have at least 1 seed token to plant.");
        require(!_seeds[x][y].isPlanted, "A seed has already been planted at these coordinates.");
        require(!_isTree[x][y], "A tree has already been grown at these coordinates.");

        _seeds[x][y] = Seed(true, false, block.timestamp, block.timestamp);
        _isTree[x][y] = false;
        emit SeedPlanted(msg.sender, x, y);
    }

    function addWater(address _address, uint256 x, uint256 y) external {
        require(msg.sender == _address, "Only a specific address can call this function.");
        require(_seeds[x][y].isPlanted, "There is no seed planted at these coordinates.");
        require(!_seeds[x][y].isWatered, "The seed has already been watered.");

        _seeds[x][y].isWatered = true;
        _seeds[x][y].lastWateredTimestamp = block.timestamp;
        emit WaterAdded(msg.sender, x, y);
    }

    function checkAndRemoveSeed(uint256 x, uint256 y) private {
        if (_seeds[x][y].isPlanted && !_seeds[x][y].isWatered && _seeds[x][y].lastWateredTimestamp + SECONDS_IN_A_DAY <= block.timestamp) {
            delete _seeds[x][y];
        }
    }

    function isSeedPlanted(uint256 x, uint256 y) external view returns (bool) {
        return _seeds[x][y].isPlanted;
    }

    function isSeedWatered(uint256 x, uint256 y) external view returns (bool) {
        if (_seeds[x][y].isWatered) {
            uint256 lastWateredTime = _seeds[x][y].lastWateredTimestamp;
            return lastWateredTime + SECONDS_IN_A_DAY >= block.timestamp;
        }
        return false;
    }

    function isSapling(uint256 x, uint256 y) public view returns (bool) {
        if (_seeds[x][y].isPlanted && block.timestamp >= _seeds[x][y].plantedTimestamp + 2 * SECONDS_IN_A_DAY) {
            return true;
        }
        return false;
    }

    function isAlive(uint256 x, uint256 y) public view returns (bool) {
        if (_seeds[x][y].isWatered) {
            uint256 lastWateredTime = _seeds[x][y].lastWateredTimestamp;
            return lastWateredTime + SECONDS_IN_A_DAY >= block.timestamp;
        }
        return false;
    }

    function setTreeContractAddress(address treeContractAddress) external {
        require(_treeContractAddress == address(0), "Tree contract address has already been set.");
        require(treeContractAddress != address(0), "Invalid tree contract address.");
        _treeContractAddress = treeContractAddress;
    }

    function generateTreeNFT(uint256 x, uint256 y) external {
        require(_treeContractAddress != address(0), "Tree contract address has not been set.");
        require(_seeds[x][y].isPlanted, "No seed planted at these coordinates.");
        require(!_isTree[x][y], "A tree has already been grown at these coordinates.");

        bool seedAlive = isAlive(x, y);
        bool seedSapling = isSapling(x, y);

        require(seedAlive && seedSapling, "The seed is not alive or hasn't reached the sapling stage yet.");

        require(
            _seeds[x][y].plantedTimestamp + 15 * SECONDS_IN_A_DAY <= block.timestamp,
            "The seed must be planted for at least 15 days."
        );

        _isTree[x][y] = true;
        Tree treeContract = Tree(_treeContractAddress);
        uint256 tokenId = treeContract.createTreeNFT(msg.sender);
        emit TreeGeneratedAt(x, y, msg.sender, tokenId);
    }
}
