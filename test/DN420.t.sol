// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "forge-std/Test.sol";

import {DN420Mock} from "./mocks/DN420Mock.sol";

contract DN420Test is Test {
    DN420Mock public token;

    event Transfer(address indexed from, address indexed to, uint256 amount);


    address public Minter1 = address(0xd125259);
    address public Minter2 = address(0xd125258);

    function setUp() public {
        token = new DN420Mock("Test", "TST", "BASE_URL", 18, 10 ** 5);
    }

    function testInitialize() public view {
        assertEq(token.name(), "Test");
        assertEq(token.symbol(), "TST");
        assertEq(token.decimals(), 18);
        assertEq(token.unit(), 10 ** 5 * 10 ** 18);
    }

    function testMint() public {
        token.mint(address(this), 2 * token.unit());
        assertEq(token.balanceOf(address(this)), 2 * token.unit());
        assertEq(token.nftBalanceOf(address(this), 0), 2);
    }

    function testMint(address to, uint256 amount) public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), to, amount);
        token.mint(to, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(to), amount);
        assertEq(token.nftBalanceOf(to, 0), amount / token.unit());
    }

    function testMintDecimalUnit() public {
        token.mint(address(this), 5 * token.unit() / 10);

        assertEq(token.balanceOf(address(this)), 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(address(this), 0), 0);

        token.mint(address(this), 8 * token.unit() / 10);
        assertEq(token.balanceOf(address(this)), 13 * token.unit() / 10);
        assertEq(token.nftBalanceOf(address(this), 0), 1);
    }

    function testBurn() public {
        token.mint(address(this), 2 * token.unit());
        token.burn(address(this), token.unit());
        assertEq(token.balanceOf(address(this)), token.unit());
        assertEq(token.nftBalanceOf(address(this), 0), 1);
    }

    function testBurnDecimalUnit() public {
        token.mint(address(this), 2 * token.unit());
        token.burn(address(this), 5 * token.unit() / 10);

        assertEq(token.balanceOf(address(this)), 2 * token.unit() - 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(address(this), 0), 1);
    }

    function testTransfer() public {
        token.mint(Minter1, 2 * token.unit());
        token.mint(Minter2, 2 * token.unit());

        vm.startPrank(Minter1);
        token.transfer(Minter2, token.unit());
        vm.stopPrank();

        assertEq(token.balanceOf(Minter2), 3 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 3);
        assertEq(token.balanceOf(Minter1),  token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 1);
    }

    function testTransferDecimalUnit() public {
        token.mint(Minter1, 2 * token.unit());
        token.mint(Minter2, 2 * token.unit());
        assertEq(token.balanceOf(Minter1),  2 * token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 2);
        assertEq(token.balanceOf(Minter2),  2 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 2);

        vm.startPrank(Minter1);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10 + 2 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 2);
        assertEq(token.balanceOf(Minter1), 15 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, 0), 1);
    }

    function testTransferFrom() public {
        token.mint(Minter1, 2 * token.unit());
        token.mint(Minter2, 2 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, token.unit());
        token.transferFrom(Minter1, Minter2, token.unit());
        vm.stopPrank();

        assertEq(token.balanceOf(Minter2), 3 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 3);
        assertEq(token.balanceOf(Minter1),  token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 1);
    }

    function testTransferFromDecimalUnit() public {
        token.mint(Minter1, 2 * token.unit());
        token.mint(Minter2, 2 * token.unit());
        assertEq(token.balanceOf(Minter1),  2 * token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 2);
        assertEq(token.balanceOf(Minter2),  2 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 2);

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transferFrom(Minter1, Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10 + 2 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 2);
        assertEq(token.balanceOf(Minter1), 15 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, 0), 1);
    }

    function testMintNFT() public {
        uint256 tokenId = 1;
        token.mint(Minter1, tokenId, 2, "");
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.balanceOf(Minter1), 2 * token.unit());
    }

    function testBurnNFT() public {
        uint256 tokenId = 1;
        token.mint(Minter1, tokenId, 2, "");
        vm.startPrank(Minter1);
        token.burn(Minter1, tokenId, 2);
        vm.stopPrank();
        assertEq(token.nftBalanceOf(Minter1, tokenId), 0);
        assertEq(token.balanceOf(Minter1), 0);
    }

    function testBurnNFTPartial() public {
        uint256 tokenId = 1;
        token.mint(Minter1, tokenId, 2, "");
        vm.startPrank(Minter1);
        token.burn(Minter1, tokenId, 1);
        vm.stopPrank();
        assertEq(token.nftBalanceOf(Minter1, tokenId), 1);
        assertEq(token.balanceOf(Minter1), token.unit());
    }


    function testMintAndTransfer() public {
        uint256 tokenId = 1;
        
        token.mint(Minter1, tokenId, 3, "");
        assertEq(token.nftBalanceOf(Minter1, tokenId), 3);
        assertEq(token.balanceOf(Minter1), 3 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        
        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 0);

        uint256 tokenId2 = 2;
        token.mint(Minter1, tokenId2, 2, "");
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 2);
        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 2 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 15 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 2);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        //
        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 10 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), token.unit() + 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        //
        token.mint(Minter1, 8 * token.unit() / 10);
        assertEq(token.balanceOf(Minter1), 35 * token.unit() / 10 + 8 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 1);

        assertEq(token.balanceOf(Minter2), token.unit() + 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        vm.startPrank(Minter2);
        token.approve(Minter2, 8 * token.unit() / 10);
        token.transfer(Minter1, 8 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 35 * token.unit() / 10 + 16 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 2);

        assertEq(token.balanceOf(Minter2), 7 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 0);

        // 
        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit());
        token.transfer(Minter2, 5 * token.unit());
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 1 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 0);
        assertEq(token.nftBalanceOf(Minter1, tokenId2), 0);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), 5 * token.unit() + 7 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 5);
        
    }

    function testMintNFTAndTransfer() public {
        uint256 tokenId = 1;
        uint256 tokenId3 = 3;
        
        token.mint(Minter1, tokenId, 3, "");
        assertEq(token.nftBalanceOf(Minter1, tokenId), 3);
        assertEq(token.balanceOf(Minter1), 3 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        
        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 0);

        
        token.mint(Minter1, tokenId3, 2, "");
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 2);
        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 2 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 15 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 2);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        //
        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 25 * token.unit() / 10 + 10 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), token.unit() + 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        //
        token.mint(Minter1, 8 * token.unit() / 10);
        assertEq(token.balanceOf(Minter1), 35 * token.unit() / 10 + 8 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 1);

        assertEq(token.balanceOf(Minter2), token.unit() + 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        vm.startPrank(Minter2);
        token.approve(Minter2, 8 * token.unit() / 10);
        token.transfer(Minter1, 8 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 35 * token.unit() / 10 + 16 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 2);
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 1);
        assertEq(token.nftBalanceOf(Minter1, 0), 2);

        assertEq(token.balanceOf(Minter2), 7 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 0);

        // 
        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit());
        token.transfer(Minter2, 5 * token.unit());
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 1 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, tokenId), 0);
        assertEq(token.nftBalanceOf(Minter1, tokenId3), 0);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);

        assertEq(token.balanceOf(Minter2), 5 * token.unit() + 7 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 5);
        
    }

    function testBatchMintAndTransfer() public {
        uint8 len = 3;
        uint256[] memory tokenIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);

        for (uint8 i = 0; i < len; i++) {
            tokenIds[i] = i + 1; // 123
            amounts[i] = i + 1;
        }
        token.batchMint(Minter1, tokenIds, amounts, "");
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 1);
        assertEq(token.nftBalanceOf(Minter1, 2), 2);
        assertEq(token.nftBalanceOf(Minter1, 3), 3);
        assertEq(token.balanceOf(Minter1), 6 * token.unit());

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 55 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 1);
        assertEq(token.nftBalanceOf(Minter1, 2), 2);
        assertEq(token.nftBalanceOf(Minter1, 3), 2);
        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 0);

        vm.startPrank(Minter1);
        token.approve(Minter1, 5 * token.unit() / 10);
        token.transfer(Minter2, 5 * token.unit() / 10);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 55 * token.unit() / 10 - 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 1);
        assertEq(token.nftBalanceOf(Minter1, 2), 2);
        assertEq(token.nftBalanceOf(Minter1, 3), 2);
        assertEq(token.isOwned(Minter1, 1), true);
        assertEq(token.isOwned(Minter1, 2), true);
        assertEq(token.isOwned(Minter1, 3), true);
        assertEq(token.isOwned(Minter1, 4), false);

        assertEq(token.balanceOf(Minter2), 5 * token.unit() / 10 + 5 * token.unit() / 10);
        assertEq(token.nftBalanceOf(Minter2, 0), 1);

        vm.startPrank(Minter1);
        uint256[] memory tokenIds2 = new uint256[](2);
        uint256[] memory amounts2 = new uint256[](2);
        tokenIds2[0] = 2;
        tokenIds2[1] = 3;
        amounts2[0] = 1;
        amounts2[1] = 1;
        token.setApprovalForAll(Minter1, true);
        token.safeBatchTransferFrom(Minter1, Minter2, tokenIds2, amounts2, "");
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 5 * token.unit() - 2 * token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 1);
        assertEq(token.nftBalanceOf(Minter1, 2), 1);
        assertEq(token.nftBalanceOf(Minter1, 3), 1);
        assertEq(token.ownedBalanceOf(Minter1), 3);
        assertEq(token.isOwned(Minter1, 1), true);
        assertEq(token.isOwned(Minter1, 2), true);
        assertEq(token.isOwned(Minter1, 3), true);
        assertEq(token.isOwned(Minter1, 4), false);

        assertEq(token.balanceOf(Minter2),  token.unit() + 2 * token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 1);
        assertEq(token.nftBalanceOf(Minter2, 1), 0);
        assertEq(token.nftBalanceOf(Minter2, 2), 1);
        assertEq(token.nftBalanceOf(Minter2, 3), 1);
        assertEq(token.ownedBalanceOf(Minter2), 2);
        assertEq(token.isOwned(Minter2, 1), false);
        assertEq(token.isOwned(Minter2, 2), true);
        assertEq(token.isOwned(Minter2, 3), true);
        assertEq(token.isOwned(Minter2, 4), false);

        // batchBurn
        uint256[] memory tokenIds3 = new uint256[](2);
        uint256[] memory amounts3 = new uint256[](2);
        tokenIds3[0] = 2;
        tokenIds3[1] = 3;
        amounts3[0] = 1;
        amounts3[1] = 1;
        vm.startPrank(Minter2);
        token.batchBurn(Minter2, tokenIds3, amounts3);
        vm.stopPrank();

        assertEq(token.balanceOf(Minter2),  token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 1);
        assertEq(token.nftBalanceOf(Minter2, 1), 0);
        assertEq(token.nftBalanceOf(Minter2, 2), 0);
        assertEq(token.nftBalanceOf(Minter2, 3), 0);
        assertEq(token.ownedBalanceOf(Minter2), 0);
        assertEq(token.isOwned(Minter2, 1), false);
        assertEq(token.isOwned(Minter2, 2), false);
        assertEq(token.isOwned(Minter2, 3), false);
        assertEq(token.isOwned(Minter2, 4), false);

        // safeTransferFrom
        vm.startPrank(Minter1);
        token.setApprovalForAll(Minter1, true);
        token.safeTransferFrom(Minter1, Minter2, 2, 1, "");
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 3 * token.unit() - token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 1);
        assertEq(token.nftBalanceOf(Minter1, 2), 0);
        assertEq(token.nftBalanceOf(Minter1, 3), 1);
        assertEq(token.ownedBalanceOf(Minter1), 2);
        assertEq(token.isOwned(Minter1, 1), true);
        assertEq(token.isOwned(Minter1, 2), false);
        assertEq(token.isOwned(Minter1, 3), true);
        assertEq(token.isOwned(Minter1, 4), false);

        assertEq(token.balanceOf(Minter2),  token.unit() + token.unit());
        assertEq(token.nftBalanceOf(Minter2, 0), 1);
        assertEq(token.nftBalanceOf(Minter2, 1), 0);
        assertEq(token.nftBalanceOf(Minter2, 2), 1);
        assertEq(token.nftBalanceOf(Minter2, 3), 0);
        assertEq(token.ownedBalanceOf(Minter2), 1);
        assertEq(token.isOwned(Minter2, 1), false);
        assertEq(token.isOwned(Minter2, 2), true);
        assertEq(token.isOwned(Minter2, 3), false);
        assertEq(token.isOwned(Minter2, 4), false);

    }

    function testBatchMintFromWhiteboard() public {
        token.mint(Minter1, 5 * token.unit());
        assertEq(token.balanceOf(Minter1), 5 * token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 5);


        vm.startPrank(Minter1);
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 3;
        amounts[1] = 2;
        token.batchMintFromBlank(Minter1, ids, amounts, "");
        vm.stopPrank();

        assertEq(token.balanceOf(Minter1), 5 * token.unit());
        assertEq(token.nftBalanceOf(Minter1, 0), 0);
        assertEq(token.nftBalanceOf(Minter1, 1), 3);
        assertEq(token.nftBalanceOf(Minter1, 2), 2);
        assertEq(token.isOwned(Minter1, 1), true);
        assertEq(token.isOwned(Minter1, 2), true);

        vm.startPrank(Minter1);
        ids[0] = 0;
        ids[1] = 2;
        amounts[0] = 3;
        amounts[1] = 2;
        vm.expectRevert(); // Minter1 has 0 blankNFT
        token.batchMintFromBlank(Minter1, ids, amounts, "");
        vm.stopPrank();
    }
}