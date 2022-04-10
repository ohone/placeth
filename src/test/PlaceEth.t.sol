// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "ds-test/test.sol";
import "../PlaceEth.sol";
import "./Hevm.sol";

contract PlaceEthTest is DSTest {
    PlaceEth CuT;
    Hevm vm = Hevm(HEVM_ADDRESS);
    uint256 cooldownSeconds = 123;

    function setUp() public {
        CuT = new PlaceEth(1024, cooldownSeconds);
    }

    function test_Place_SetsColor() public {
        // act
        bytes32 place = bytes32(uint256(100));
        CuT.place(255, place);

        // assert
        assertEq(CuT.board(place), 255);
    }

    event placed(uint256 color, bytes32 indexed place, address user);

    function test_Place_EmitsEvent(uint256 color, bytes32 position) public {
        vm.assume(color != 0);
        if (uint256(position) > CuT.boardSize()) {
            return;
        }

        vm.expectEmit(true, true, false, false);
        emit placed(color, position, address(this));
        CuT.place(color, position);
    }

    function test_Place_ExistingColor_Reverts(bytes32 position) public {
        if (uint256(position) > CuT.boardSize()) {
            return;
        }

        vm.expectRevert("colour already placed");
        CuT.place(0, position);
    }

    function test_Place_OutOfBounds_Reverts(bytes32 position) public {
        if (uint256(position) <= CuT.boardSize()) {
            return;
        }

        vm.expectRevert("out of bounds");
        CuT.place(0, position);
    }

    function test_Place_BeforeCooldown_Reverts() public {
        // arrange
        bytes32 place = bytes32(uint256(100));
        CuT.place(255, place);
        assertEq(CuT.board(place), 255);
        vm.warp(cooldownSeconds - 1);

        // act/assert
        vm.expectRevert("address still on cooldown");
        CuT.place(251, place);
    }

    function test_Place_AfterCooldown() public {
        // arrange
        bytes32 place = bytes32(uint256(100));
        CuT.place(255, place);
        assertEq(CuT.board(place), 255);
        vm.warp(cooldownSeconds);

        // act/assert
        CuT.place(251, place);
        assertEq(CuT.board(place), 251);
    }
}
