// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error INSUFFICIENT_BALANCE();
error INSUFFICIENT_PRICE();
error UNSUCCESSFUL_WITHDRAWAL();

contract NiftyMinty is
    Ownable,
    ERC721Burnable,
    ERC721Enumerable,
    ERC721Royalty,
    ERC721URIStorage
{
    using Counters for Counters.Counter;

    Counters.Counter public _tokenId;

    uint256 public mintingPrice = 0.001 ether;
    uint256 public constant MAX_SUPPLY = 1000;
    string private baseUri_;

    event NewMint(address indexed sender, uint256 amountPaid, uint256 tokenId);
    event Withdraw(address indexed sender, uint256 amount);

    constructor(string memory uri)
        ERC721("Nifty Minty Collection", "NMC")
        Ownable()
    {
        baseUri_ = uri;
    }

    function mint(address to) external payable {
        if (msg.value < mintingPrice) {
            revert INSUFFICIENT_PRICE();
        }
        _tokenId.increment();
        _mint(to, _tokenId.current());
        emit NewMint(msg.sender, msg.value, _tokenId.current());
    }

    function withdraw(address payable to, uint256 amount)
        external
        returns (bool success)
    {
        uint256 bal = address(this).balance;
        if (bal < amount) {
            revert INSUFFICIENT_BALANCE();
        }
        (success, ) = to.call{value: amount}("");
        if (!success) revert INSUFFICIENT_PRICE();
        emit Withdraw(msg.sender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721Royalty, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseUri_;
    }
}
