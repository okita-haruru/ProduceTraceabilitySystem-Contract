pragma solidity ^0.8.0;
import "./Model.sol";
import "./Event.sol";
import "./ProductBase.sol";
import "./ScoreBase.sol";

contract ProductTraceabilitySystem is Model, Event, ProductBase, ScoreBase {
    address[] productionUnitAddrs;
    address admin;
    mapping(address => ProductionUnit) AddrToUnit;
    mapping(uint32 => ProductionUnit) IDToUnit;
    mapping(bytes32 => User) IDToUser;

    function generateProductID(
        uint32 _productionUnitID,
        uint32 _timeStamp,
        uint16 _num
    ) public override returns (bytes32[] memory IDs) {
        //IDs = new uint[](_num);
        for (uint16 i = 0; i < _num; i++) {
            IDs[i] = keccak256(
                abi.encodePacked(_productionUnitID, _timeStamp, i)
            );
            emit Confirm(IDs[i], _productionUnitID, 0, _timeStamp);
        }
    }

    function confirm(
        bytes32 _productionID,
        uint32 _timeStamp,
        uint32 _productionUnitID,
        uint8 _state
    ) public override {
        require(AddrToUnit[msg.sender].ID == _productionUnitID);
        emit Confirm(_productionID, _productionUnitID, _state, _timeStamp);
    }

    function score(
        bytes32 _userID,
        uint32 _productionUnitID,
        uint32 _timeStamp,
        uint8 _score
    ) public override {
        require(!IDToUser[_userID].banned);
        emit Score(_userID, _productionUnitID, _timeStamp, _score);
        IDToUnit[_productionUnitID].scores += _score;
        IDToUnit[_productionUnitID].power++;
        updateScore(_productionUnitID);
    }

    function updateScore(uint32 _productionUnitID) internal {
        IDToUnit[_productionUnitID].score = uint8(
            IDToUnit[_productionUnitID].scores /
                IDToUnit[_productionUnitID].power
        );
    }

    function ban(bytes32 _userID) public {
        require(msg.sender == admin);
        IDToUser[_userID].banned = true;
    }

    function sanction(uint32 _productionUnitID, uint32 _timeStamp) external {
        require(msg.sender == admin);
        IDToUnit[_productionUnitID].score=0;
        IDToUnit[_productionUnitID].power=0;
        IDToUnit[_productionUnitID].scores=0;
        emit Sanction(_productionUnitID, _timeStamp);
    }
}
