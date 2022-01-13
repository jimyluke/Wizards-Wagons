//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoQuestDM is ERC721Enumerable, Ownable {
  using Strings for uint256;
  string private baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public preSaleCost = 0.07 ether;
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 5000;
  uint256 public preSaleMaxSupply = 250;
  uint256 public maxMintAmountPresale = 3;
  uint256 public maxMintAmount = 10;
  uint256 public nftPerAddressLimitPresale = 3;
  uint256 public nftPerAddressLimit = 10;
  uint256 public preSaleDate = 1638738000;
  uint256 public preSaleEndDate = 1638824400;
  uint256 public publicSaleDate = 1638842400;
  bool public paused = false;
  bool public revealed = false;
  mapping(address => bool) whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initNotRevealedUri,
    string memory _newBaseURI
  ) ERC721(_name, _symbol) {
    setNotRevealedURI(_initNotRevealedUri);
    setBaseURI(_newBaseURI);
    // mint(250);
  }

  //MODIFIERS
  modifier notPaused {
    require(!paused, "the contract is paused");
    _;
  }

  modifier saleStarted {
    require(block.timestamp >= preSaleDate, "Sale has not started yet");
    _;
  }

  modifier minimumMintAmount(uint256 _mintAmount) {
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    _;
  }

  // INTERNAL
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function presaleValidations(
    uint256 _ownerMintedCount,
    uint256 _mintAmount,
    uint256 _supply
  ) internal {
    uint256 actualCost;
    block.timestamp < preSaleEndDate
      ? actualCost = preSaleCost
      : actualCost = cost;
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

  function publicsaleValidations(uint256 _ownerMintedCount, uint256 _mintAmount)
    internal
  {
    require(
      _ownerMintedCount + _mintAmount <= nftPerAddressLimit,
      "max NFT per address exceeded"
    );
    require(msg.value >= cost * _mintAmount, "insufficient funds");
    require(
      _mintAmount <= maxMintAmount,
      "max mint amount per transaction exceeded"
    );
  }

  //MINT
  function mint(uint256 _mintAmount)
    public
    payable
    notPaused
    saleStarted
    minimumMintAmount(_mintAmount)
  {
    uint256 supply = totalSupply();
    uint256 ownerMintedCount = addressMintedBalance[msg.sender];

    //Do some validations depending on which step of the sale we are in
    block.timestamp < publicSaleDate
      ? presaleValidations(ownerMintedCount, _mintAmount, supply)
      : publicsaleValidations(ownerMintedCount, _mintAmount);

    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
    }
  }

  //PUBLIC VIEWS
  function isWhitelisted(address _user) public view returns (bool) {
    return whitelistedAddresses[_user];
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if (!revealed) {
      return notRevealedUri;
    } else {
      string memory currentBaseURI = _baseURI();
      return
        bytes(currentBaseURI).length > 0
          ? string(
            abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)
          )
          : "";
    }
  }

  function getCurrentCost() public view returns (uint256) {
    if (block.timestamp < preSaleEndDate) {
      return preSaleCost;
    } else {
      return cost;
    }
  }

  //ONLY OWNER VIEWS
  function getBaseURI() public view onlyOwner returns (string memory) {
    return baseURI;
  }

  function getContractBalance() public view onlyOwner returns (uint256) {
    return address(this).balance;
  }

  //ONLY OWNER SETTERS
  function reveal() public onlyOwner {
    revealed = true;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setNftPerAddressLimitPreSale(uint256 _limit) public onlyOwner {
    nftPerAddressLimitPresale = _limit;
  }

  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }

  function setPresaleCost(uint256 _newCost) public onlyOwner {
    preSaleCost = _newCost;
  }

  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmountPreSale(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmountPresale = _newmaxMintAmount;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setPresaleMaxSupply(uint256 _newPresaleMaxSupply) public onlyOwner {
    preSaleMaxSupply = _newPresaleMaxSupply;
  }

  function setMaxSupply(uint256 _maxSupply) public onlyOwner {
    maxSupply = _maxSupply;
  }

  function setPreSaleDate(uint256 _preSaleDate) public onlyOwner {
    preSaleDate = _preSaleDate;
  }

  function setPreSaleEndDate(uint256 _preSaleEndDate) public onlyOwner {
    preSaleEndDate = _preSaleEndDate;
  }

  function setPublicSaleDate(uint256 _publicSaleDate) public onlyOwner {
    publicSaleDate = _publicSaleDate;
  }

  function whitelistUsers(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      whitelistedAddresses[addresses[i]] = true;
    }
  }

  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{ value: address(this).balance }(
      ""
    );
    require(success);
  }
}