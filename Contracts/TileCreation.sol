pragma solidity ^0.4.4;

import "openzeppelin-solidity/contracts/Math/SafeMath.sol";

contract TileCreation{

    //Using safemath
    using SafeMath for uint256;
    //Events
    event UpdatedTile(uint tileId);
    
    // Tile struct
    struct Tile {
        int8 x;
        int8 y;
    }

    int8 ResourceType;
    int8 ResourceAmount;

    // -- Storage --
    // World
    Tile[] tiles;
    mapping (int => mapping(int => uint)) positionToTileId;
    mapping (uint => address) tileIdToOwner;
    mapping (address => uint) ownershipCount;

    function createTile(int8 _x, int8 _y) internal {
        // TODO - make sure position isn't already occupied
        //   and that it is valid (next to another tile)
        uint id = tiles.push(Tile(_x, _y)) - 1;
        positionToTileId[_x][_y] = id;
    }
    
    uint randNonce = 0;

    //Function to create psuedo-random uints for resource type and amount
    function randomResources(int8 Xpos, int8 Ypos) internal {
        ResourceType = int8(keccak256(now, randNonce, Xpos, Ypos)) % 100;
        randNonce++;
        ResourceAmount = int8(keccak256(now, randNonce, Xpos, Ypos)) % 100;
    }

    function RealmBase() public {
        // Create base tiles with resources
        //(should this have an onlyOwner modifier?)

        // Genesis tile! id = 0
        createTile(0, 0);
        randomResources(0,0);

        createTile(0, -1);
        randomResources(0,-1);

        createTile(0, 1);
        randomResources(0,1);

        createTile(-1, 0);
        randomResources(-1,0);

        createTile(1, 0);
        randomResources(1,0);

        createTile(1, -1);
        randomResources(1,-1);

        createTile(-1, 1);
        randomResources(-1,1);

    }

    function tileExists(int8 _x, int8 _y) internal view returns(bool) {
        if ( (_x != 0 || _y != 0) && (positionToTileId[_x][_y] == 0)) {
            return false;
        }
        return true;
    }
    
    /** @dev function for creating a new "guy"
      * @return worked Whether or not claim went through
      */
    function ClaimTile(uint _id) public returns(bool) {
        require(tileIdToOwner[_id] == address(0));

        // If we are claiming a tile for the first time
        Tile t = tiles[_id];
        if (!tileExists(t.x+1, t.y)) {
            createTile(t.x+1, t.y);
        }
        if (!tileExists(t.x, t.y+1)) {
            createTile(t.x, t.y+1);
        }
        if (!tileExists(t.x-1, t.y)) {
            createTile(t.x-1, t.y);
        }
        if (!tileExists(t.x, t.y-1)) {
            createTile(t.x, t.y-1);
        }
        if (!tileExists(t.x+1, t.y-1)) {
            createTile(t.x+1, t.y-1);
        }
        if (!tileExists(t.x-1, t.y+1)) {
            createTile(t.x-1, t.y+1);
        }

        tileIdToOwner[_id] = msg.sender;
        emit UpdatedTile(_id);
        // emit NewGuy(id, _name, _dna);
    }

    /** @dev Returns the amount of tiles in the world
      * @return length The length of tiles in the world.
      */
    function GetTileCount() public view returns(uint) {
        return tiles.length;
    }

    /** @dev Gets data for a specific tile in the world
      * @param _id id of the tile to get data for.
      * @return owner The address of the owner of this tile.
      * @return x The x position of this tile.
      * @return y The y position of this tile.
      */
    function GetTile(uint _id) public view returns(address, int8, int8) {
        return (tileIdToOwner[_id], tiles[_id].x, tiles[_id].y);
    }

}