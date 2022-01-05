//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CryptoQuestDM is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;
    bool public sale = false;

    uint256 public constant MAX_ITEMS = 5000;
    uint256 public constant MAX_MINT = 10;
    address public constant devAddress = 0xfF56DAA879FD54d137A0601e6a11f0ED89Ce8829;
    string public baseTokenURI;
    uint256 public basePrice = 0.07 ether;
    uint256 public batch = 0;
    uint256 public preSaleCost = 0.05 ether;
    uint256 public preSaleMaxSupply = 2250;
    uint256 public maxMintAmountPresale = 1;
    uint256 public maxMintAmount = 10;
    uint256 public nftPerAddressLimitPresale = 1;
    uint256 public nftPerAddressLimit = 100;
    uint256 public preSaleDate = 1638738000;
    uint256 public preSaleEndDate = 1638824400;
    uint256 public publicSaleDate = 1638842400;

    event CreateNft(uint256 indexed id);
    event AttributeChanged(uint256 indexed _tokenId, string _key, string _value);

    constructor(string memory baseURI) ERC721("Crypto Quest: Dawn of Man", "CQDM") {
        setBaseURI(baseURI);
        sale = false;
    }

    mapping(address => bool) whitelistedAddresses;
    mapping(address => uint256) public addressMintedBalance;

    modifier saleIsOpen {
        require(_totalSupply() <= MAX_ITEMS*batch, "Sale ended");
        require(sale == false, "Sale is closed");
        if (_msgSender() != owner()) {
            require(!paused(), "Pausable: paused");
        }
        _;
    }

    // modifier onlyOwner {
    //     require(msg.sender == owner, "Ownable: caller is not the owner");
    //     _;
    // }

    modifier saleStarted {
        require(block.timestamp >= preSaleDate, "Sale has not started yet");
        _;
    }

    // modifier isWhitelisted(address _address) {
    //     require(whitelistedAddresses[_address], "You need to be whitelisted");
    //     _;
    // }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    function mint(address _to, uint256 _count) public payable saleIsOpen {
        uint256 total = _totalSupply();
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require(sale == false, "Sale has not yet started");
        require(total <= MAX_ITEMS*batch, "Sale ended");
        require(total + _count <= MAX_ITEMS*batch, "Max limit");
        require(_count <= MAX_MINT, "Exceeds number");
        require(msg.value >= price(_count), "Value below price");

        block.timestamp < publicSaleDate
        ? presaleValidations(ownerMintedCount, _count, total)
        : publicsaleValidations(ownerMintedCount, _count);

        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(_to);
        }
    }

    // function mint(uint256 _mintAmount)
    //     public
    //     payable
    //     notPaused
    //     saleStarted
    //     minimumMintAmount(_mintAmount)
    // {
    //     uint256 supply = totalSupply();
    //     uint256 ownerMintedCount = addressMintedBalance[msg.sender];

    //     //Do some validations depending on which step of the sale we are in
    //     block.timestamp < publicSaleDate
    //     ? presaleValidations(ownerMintedCount, _mintAmount, supply)
    //     : publicsaleValidations(ownerMintedCount, _mintAmount);

    //     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    //     for (uint256 i = 1; i <= _mintAmount; i++) {
    //     addressMintedBalance[msg.sender]++;
    //     _safeMint(msg.sender, supply + i);
    //     }
    // }

    function publicsaleValidations(uint256 _ownerMintedCount, uint256 _mintAmount)
        internal
    {
        require(
        _ownerMintedCount + _mintAmount <= nftPerAddressLimit,
        "max NFT per address exceeded"
        );
        require(msg.value >= basePrice * _mintAmount, "insufficient funds");
        require(
        _mintAmount <= maxMintAmount,
        "max mint amount per transaction exceeded"
        );
    }

    function _mintAnElement(address _to) private {
        // @dev start token id at 1 instead of 0
        _tokenIdTracker.increment();
        uint id = _totalSupply();
        _safeMint(_to, id);
        emit CreateNft(id);
    }

    function price(uint256 _count) public view returns (uint256) {
        return basePrice.mul(_count);
    }

    function changePrice(uint256 priceToChange) public onlyOwner {
        basePrice = priceToChange;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokenIds;
    }

    function pause(bool val) public onlyOwner {
        if (val == true) {
            _pause();
            return;
        }
        _unpause();
    }
    
    function toggleSale() public onlyOwner {
        if(sale == false) {
            batch = batch+1;
        }
        sale = !sale;
    }

    // function changeAttribute(uint256 tokenId, string memory key, string memory value) public payable {
    //     address owner = ERC721.ownerOf(tokenId);
    //     require(_msgSender() == owner, "This is not your NFT.");

    //     // uint256 amountPaid = msg.value;
    //     // require(amountPaid == RENAME_PRICE, "There is a price for changing your attributes.");

    //     emit AttributeChanged(tokenId, key, value);
    // }

    function withdrawAll() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _widthdraw(devAddress, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success,) = _address.call{value : _amount}("");
        require(success, "Transfer failed.");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function addUser (address _addressToWhitelist) public onlyOwner {
        whitelistedAddresses[_addressToWhitelist] = true;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    function presaleValidations(
        uint256 _ownerMintedCount,
        uint256 _mintAmount,
        uint256 _supply
    ) internal {
        uint256 actualCost;
        block.timestamp < preSaleEndDate
        ? actualCost = preSaleCost
        : actualCost = basePrice;
        require(isWhitelisted(msg.sender), "user is not whitelisted");
        require(
        _ownerMintedCount + _mintAmount <= nftPerAddressLimitPresale,
        "max NFT per address exceeded for presale"
        );
        require(msg.value >= actualCost * _mintAmount, "insufficient funds");
        require(
        _mintAmount <= maxMintAmountPresale,
        "max mint amount per transaction exceeded"
        );
        require(
        _supply + _mintAmount <= preSaleMaxSupply,
        "max NFT presale limit exceeded"
        );
    }

    function setNftPerAddressLimitPreSale(uint256 _limit) public onlyOwner {
        nftPerAddressLimitPresale = _limit;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        preSaleCost = _newCost;
    }

    function isWhitelisted(address _user) public view returns (bool) {
        return whitelistedAddresses[_user];
    }
}