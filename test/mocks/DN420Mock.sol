// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DN420} from "../../src/DN420.sol";

contract DN420Mock is DN420 {
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint8 decimals_,
        uint256 tokenUnit_
    ) DN420(name_, symbol_, baseURI_, decimals_, tokenUnit_) {}

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public {
        _burn(from, value);
    }

    // 1155
    function uri(uint256) public view override returns (string memory) {
        return baseURI;
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        _mint(to, id, amount, data);
    }

    function batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        _batchMint(to, ids, amounts, data);
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public {
        _burn(from, id, amount);
    }

    function batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        _batchBurn(from, ids, amounts);
    }

}