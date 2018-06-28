pragma solidity ^0.4.4;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/Math/SafeMath.sol";

contract Realm721 is TileCreation, ERC721{

    //Using safemath
    using SafeMath for uint256;

    //Ownership modifier (how can I access 'tileId'?)
    modifier onlyTileOwner(uint tileId){
        require(msg.sender == tileIdToOwner[tileId]);
        _;
    }

    //Mapping for tile approvals
    mapping(uint => address) tileApprovals;

    //Approval function
    function approve(address _to, uint256 _tokenId) public onlyTileOwner(tileId) {
        tileApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }

    //Token transfer logic 
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownershipCount[_to] = ownershipCount[_to].add(1);
        ownershipCount[msg.sender] = ownershipCount[msg.sender].sub(1);
        tileIdToOwner[_tokenId] = _to;
        Transfer(_from, _to, _tokenId);
    }

    //Transfer function (only owner)
    function transfer(address _to, uint256 _tokenId) public onlyTileOwner(tileId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    //Returns balance for a specific account
    function balanceOf(address _owner) public view returns (uint256) {
        return ownershipCount[_owner];
    }

    //Returns owner of a given token ID
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return tileIdToOwner[_tokenId];
    }

    //Transfer function (approval method)
    function takeOwnership(uint256 _tokenId) public {
        require(tileApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}