// SPDX-License-Identifier: MIT
import "./ERC1155.sol";

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QeyNFT is ERC1155, Ownable {
    struct Parcel {
        uint256 parcelType;
        uint256 amountNumber;
    }

    struct ParcelToken {
        uint256 id;
        address creator;
        uint256 parcelId;
    }

    struct GenesisToken {
        uint256 id;
        address creator;
        uint256 category;
    }

    mapping (uint256 => Parcel ) public Parcels;
    mapping (uint256 => ParcelToken ) public ParcelTokens;
    mapping (uint256 => GenesisToken ) public GenesisTokens;

    uint256 parcelCount = 1;
    uint256 genesisCount = 3939;

    uint256[] private restParcels;

    event mintParcel(address creator, uint256 tokenId, uint256 parcelId);
    event mintGenesis(address creator, uint256 tokenId, uint256 category);

    constructor() public ERC1155() {
        for (uint256 i = 1;i < 3939;i++){
            restParcels.push(i);
        }
    }

    function setParcel(Parcel[] memory _parcels) public onlyOwner {
        for (uint256 i = 0; i < _parcels.length; i++) {
            Parcels[i+1] = Parcel(_parcels[i].parcelType, _parcels[i].amountNumber);
        }
    }

    function mint() public {
        require(parcelCount < 3939, "Max mint amount is reached");

        _mint(msg.sender, parcelCount, 1, "");
        uint256 _index = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % restParcels.length;
        ParcelTokens[parcelCount] = ParcelToken(parcelCount, msg.sender, restParcels[_index]);
        emit mintParcel(msg.sender, parcelCount, restParcels[_index]);

        delete restParcels[_index];
        parcelCount++;
    }

    function burnParcel(uint256 p1TokenId, uint256 p2TokenId, uint256 p3TokenId, uint256 p4TokenId) public {
        require((p1TokenId != 0 && p2TokenId != 0 && p3TokenId != 0) || p4TokenId != 0, "You should set correct token ID");

        uint256 _sum = 0;
        if (p4TokenId != 0){
            require(balanceOf(msg.sender, p4TokenId) > 0, "You should be owner of the token");
            require(Parcels[ParcelTokens[p4TokenId].parcelId].parcelType == 4, "Please set correct token ID for parcel");
            _burn(msg.sender, p4TokenId, 1);
            _sum = 8;
        }else{
            require(balanceOf(msg.sender, p1TokenId) > 0 && balanceOf(msg.sender, p2TokenId) > 0 && balanceOf(msg.sender, p3TokenId) > 0, "You should be owner of the tokens");
            require(Parcels[ParcelTokens[p1TokenId].parcelId].parcelType == 1 && Parcels[ParcelTokens[p2TokenId].parcelId].parcelType == 2 && Parcels[ParcelTokens[p3TokenId].parcelId].parcelType == 3, "Please set correct combinations of parcels");
            _burn(msg.sender, p1TokenId, 1);
            _burn(msg.sender, p2TokenId, 1);
            _burn(msg.sender, p3TokenId, 1);
            _sum = Parcels[ParcelTokens[p1TokenId].parcelId].amountNumber + Parcels[ParcelTokens[p2TokenId].parcelId].amountNumber + Parcels[ParcelTokens[p3TokenId].parcelId].amountNumber;
        }
        GenesisTokens[genesisCount] = GenesisToken(genesisCount, msg.sender, _sum - 2);
        _mint(msg.sender, genesisCount, 1, "");
        emit mintGenesis(msg.sender, parcelCount, _sum - 2);
    }

    function uri(uint256 _tokenId) public view override returns (string memory _uri) {
        return _tokenURI(_tokenId);
    }

    function setTokenUri(uint256 _tokenId, string memory _uri) public onlyOwner {
        _setTokenURI(_tokenId, _uri);
    }
}
