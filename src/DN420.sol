// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import {LibBitmap} from  "@vectorized/solady/utils/LibBitmap.sol";

import {ERC20} from "./ERC20.sol";
import {ERC1155} from "./ERC1155.sol";

abstract contract DN420 is ERC20, ERC1155 {
    using LibBitmap for LibBitmap.Bitmap;

    uint256 public maxTokenId;
    uint256 public tokenUnit;
    string public baseURI;

    mapping(address => LibBitmap.Bitmap) private _owned;
    // Record the number of non-whiteboard NFTs owned by the user
    mapping(address => uint256) private _ownedBalanceOf;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint8 _decimals,
        uint256 _tokenUnit
    ) ERC20(_name, _symbol, _decimals) {
        baseURI = _baseURI;
        tokenUnit = _tokenUnit;
    }

    /// @notice Returns the unit value for token calculations
    /// @return The token unit multiplied by 10^decimals
    function unit() public view  returns (uint256) {
        return tokenUnit * 10 ** decimals;
    }

    /// @notice Calculates the total supply of NFTs
    /// @return The total number of NFTs
    function totalNFTSupply() public view returns (uint256) {
        return totalSupply / unit();
    }

    function _mint(address to, uint256 value) internal override(ERC20) virtual {
        ERC20._mint(to, value);
        _afterTokenTransfer(address(0), to);
    }

    function _burn(address from, uint256 amount) internal override(ERC20) virtual {
        ERC20._burn(from, amount);
        _afterTokenTransfer(msg.sender, address(0));
    }

     function transfer(address to, uint256 amount) public virtual override(ERC20) returns (bool) {
       ERC20._transfer(to, amount);
       _afterTokenTransfer(msg.sender, to);
       return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override(ERC20) returns (bool) {
        ERC20._transferFrom(from, to, amount);
        _afterTokenTransfer(from, to);
        return true;
    }

    function uri(uint256 id) override public view virtual returns (string memory);

    /// @notice Checks if a specific token ID is owned by an address
    /// @param owner The address to check
    /// @param id The token ID to check
    /// @return True if the address owns the token ID, false otherwise
    function isOwned(address owner, uint256 id) public view returns (bool) {
        return _owned[owner].get(id);
    }

    /// @notice Gets the balance of non-whiteboard NFTs owned by an address
    /// @param owner The address to check
    /// @return The number of non-whiteboard NFTs owned
    function ownedBalanceOf(address owner) public view returns (uint256) {
        return _ownedBalanceOf[owner];
    }

    /// @notice Mints a new NFT
    /// @param to The recipient address
    /// @param id The token ID to mint
    /// @param amount The amount of tokens to mint
    /// @param data Additional data for the minting process
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override(ERC1155) virtual {
        maxTokenId = id > maxTokenId ? id : maxTokenId;
        ERC1155._mint(to, id, amount, data);
        _ownedBalanceOf[to] += amount;
        _owned[to].set(id);
        _afterSigleTransfer(address(0), to, id, amount);
    }

    /// @notice Burns an existing NFT
    /// @param from The address to burn from
    /// @param id The token ID to burn
    /// @param amount The amount of tokens to burn
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal override(ERC1155) virtual {
        ERC1155._burn(from, id, amount);
        _ownedBalanceOf[from] -= amount;
        if (nftBalanceOf[from][id] == 0) {
            _owned[from].unset(id);
        }
        _afterSigleTransfer(from, address(0), id, amount);
    }

    /// @notice Mints a new NFT from a blank token
    /// @param to The recipient address
    /// @param id The token ID to mint
    /// @param amount The amount of tokens to mint
    /// @param data Additional data for the minting process
    function mintFromBlank(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        maxTokenId = id > maxTokenId ? id : maxTokenId;
        
        nftBalanceOf[msg.sender][0] -= amount;
        _ownedBalanceOf[to] += amount;
        _owned[to].set(id);
        ERC1155._mint(to, id, amount, data);
    }

    /// @notice Mints NFTs from the blank token (0) to a specified address
    /// @param from The address to mint from (should be the blank token)
    /// @param to The address to receive the minted NFTs
    /// @param id The token ID to mint
    /// @param amount The amount of tokens to mint
    /// @param data Additional data to pass to the receiver
    function _mintFromBlank(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        maxTokenId = id > maxTokenId ? id : maxTokenId;
        
        nftBalanceOf[from][0] -= amount;
        _ownedBalanceOf[to] += amount;
        _owned[to].set(id);
        ERC1155._mint(to, id, amount, data);
    }

    /// @notice Burns an NFT and converts it back to a blank token
    /// @param id The token ID to burn
    /// @param amount The amount of tokens to burn
    function burnToBlank(uint256 id, uint256 amount) public virtual {
        ERC1155._burn(msg.sender, id, amount);
        _ownedBalanceOf[msg.sender] -= amount;
        if (nftBalanceOf[msg.sender][id] == 0) {
            _owned[msg.sender].unset(id);
        }
        nftBalanceOf[msg.sender][0] += amount;
    }

    /// @notice Batch mints new NFTs from blank tokens
    /// @param to The recipient address
    /// @param ids An array of token IDs to mint
    /// @param amounts An array of amounts for each token ID
    /// @param data Additional data for the minting process
    function batchMintFromBlank(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        uint256 idsLength = ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            maxTokenId = ids[i] > maxTokenId ? ids[i] : maxTokenId;

            nftBalanceOf[msg.sender][0] -= amounts[i];
            _ownedBalanceOf[to] += amounts[i];
            _owned[to].set(ids[i]);
            ERC1155._mint(to, ids[i], amounts[i], data);
        }
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) virtual {
        ERC1155._batchMint(to, ids, amounts, data);
        uint256 idsLength = ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            maxTokenId = ids[i] > maxTokenId ? ids[i] : maxTokenId;
            _ownedBalanceOf[to] += amounts[i];
            _owned[to].set(ids[i]);
        }
        _afterBatchTransfer(address(0), to, ids, amounts);
    }

   
    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override(ERC1155) virtual {
        ERC1155._batchBurn(from, ids, amounts);
        uint256 idsLength = ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            if (nftBalanceOf[from][ids[i]] == 0) {
                _ownedBalanceOf[from] -= amounts[i];
                _owned[from].unset(ids[i]);
            }
        }
        _afterBatchTransfer(from, address(0), ids, amounts);
    }

    /// @notice Safely transfers a single NFT
    /// @param from The sender address
    /// @param to The recipient address
    /// @param id The token ID to transfer
    /// @param amount The amount of tokens to transfer
    /// @param data Additional data for the transfer
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        _safeTransferFrom(from, to, id, amount, data);
        _ownedBalanceOf[from] -= amount;
        _ownedBalanceOf[to] += amount;
        _owned[to].set(id);
        if (nftBalanceOf[from][id] == 0) {
            _owned[from].unset(id);
        }
        _afterSigleTransfer(from, to, id, amount);
    }

    /// @notice Safely transfers multiple NFTs in a batch
    /// @param from The sender address
    /// @param to The recipient address
    /// @param ids An array of token IDs to transfer
    /// @param amounts An array of amounts for each token ID
    /// @param data Additional data for the transfer
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
        uint256 idsLength = ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            _ownedBalanceOf[from] -= amounts[i];
            _ownedBalanceOf[to] += amounts[i];
            _owned[to].set(ids[i]);
            if (nftBalanceOf[from][ids[i]] == 0) {
                _owned[from].unset(ids[i]);
            }
        }
        _afterBatchTransfer(from, to, ids, amounts);
    }

    /// @notice Handles token balance updates after a transfer
    /// @param from The sender address
    /// @param to The recipient address
    function _afterTokenTransfer(address from, address to) internal virtual {
        if (to != address(0)) {
            uint256 toTokenBalance = tokenBalanceOf[to];
            uint256 toOwnedBalance = _ownedBalanceOf[to];
            uint256 toZeroNftBalance = (toTokenBalance - toOwnedBalance * unit()) / unit();
            nftBalanceOf[to][0] = toZeroNftBalance;
        }

        if (from != address(0)) {
            uint256 fromTokenBalance = tokenBalanceOf[from];
            uint256 fromOwnedBalance = _ownedBalanceOf[from];
            uint256 fromLeftNftBalance = fromTokenBalance / unit();

            if (fromLeftNftBalance > fromOwnedBalance) {
                nftBalanceOf[from][0] = fromLeftNftBalance - fromOwnedBalance;
            } else {
                nftBalanceOf[from][0] = 0;
                uint256 diff = fromOwnedBalance - fromLeftNftBalance;
                uint256 lastTokenId = maxTokenId;
                while (diff > 0 && lastTokenId > 0) {
                    uint256 lastId = _owned[from].findLastSet(lastTokenId);
                    if (lastId == LibBitmap.NOT_FOUND) {
                        break;
                    }
                    uint256 lastIdAmount = nftBalanceOf[from][lastId];
                    if (lastIdAmount > diff) {
                        nftBalanceOf[from][lastId] -= diff;
                        _ownedBalanceOf[from] -= diff;
                        diff = 0;
                    } else {
                        diff -= lastIdAmount;
                        nftBalanceOf[from][lastId] = 0;
                        _owned[from].unset(lastId);
                        _ownedBalanceOf[from] -= lastIdAmount;
                        lastTokenId = lastId - 1;
                    }
                }
            }
        }
    }

    /// @notice Handles token balance updates after a single NFT transfer
    /// @param from The sender address
    /// @param to The recipient address
    /// @param amount The amount of tokens transferred
    function _afterSigleTransfer(
        address from,
        address to,
        uint256,
        uint256 amount
    ) internal virtual {
        uint256 tokenAmount = amount * unit();
        if (from != address(0)) {
            tokenBalanceOf[from] -= tokenAmount;
            totalSupply -= tokenAmount;
        }
        if (to != address(0)) {
            tokenBalanceOf[to] += tokenAmount;
            totalSupply += tokenAmount;
        }   
    }
     
    /// @notice Handles token balance updates after a batch NFT transfer
    /// @param from The sender address
    /// @param to The recipient address
    /// @param ids An array of token IDs transferred
    /// @param amounts An array of amounts for each token ID
    function _afterBatchTransfer(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 tokenAmount;
        uint256 idsLength = ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            uint256 idTokenAmount = amounts[i] * unit();
            tokenAmount += idTokenAmount;
        }

        if (from != address(0)) {
            tokenBalanceOf[from] -= tokenAmount;
            totalSupply -= tokenAmount;
        }

        if (to != address(0)) {
            tokenBalanceOf[to] += tokenAmount;
            totalSupply += tokenAmount;
        }
    }
}