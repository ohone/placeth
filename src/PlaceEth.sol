// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract PlaceEth {
    event placed(uint256 color, bytes32 indexed place, address user);
    uint256 public boardSize;
    uint256 public cooldownSeconds;
    mapping(bytes32 => uint256) public board;
    mapping(address => uint256) public cooldowns;

    modifier validPlace(uint256 color, bytes32 position) {
        require(board[position] != color, "color already placed");
        _;
    }

    modifier withinBoard(bytes32 position) {
        require(uint256(position) <= boardSize, "out of bounds");
        _;
    }

    modifier userTimeout() {
        require(
            cooldowns[msg.sender] <= block.timestamp,
            "address still on cooldown"
        );
        cooldowns[msg.sender] = block.timestamp + cooldownSeconds;
        _;
    }

    constructor(uint256 size, uint256 cooldownSecs) {
        boardSize = size;
        cooldownSeconds = cooldownSecs;
    }

    function place(uint256 color, bytes32 position)
        external
        withinBoard(position)
        validPlace(color, position)
        userTimeout
    {
        board[position] = color;
        emit placed(color, position, msg.sender);
    }
}
