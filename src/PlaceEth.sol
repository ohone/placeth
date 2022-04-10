// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract PlaceEth {
    event placed(uint256 color, bytes32 indexed place, address user);
    uint256 public boardSize;
    mapping(bytes32 => uint256) public board;

    constructor(uint256 size) {
        boardSize = size;
    }

    function place(uint256 color, bytes32 position)
        external
        withinBoard(position)
    {
        require(board[position] != color, "colour already placed");

        board[position] = color;
        emit placed(color, position, msg.sender);
    }

    modifier withinBoard(bytes32 position) {
        require(uint256(position) <= boardSize, "out of bounds");
        _;
    }
}