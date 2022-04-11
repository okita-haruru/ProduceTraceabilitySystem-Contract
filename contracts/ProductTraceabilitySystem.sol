pragma solidity ^0.8.0;
import "./Model.sol";
import "./Event.sol";
import "./ProductBase.sol";
import "./ScoreBase.sol";

contract ProductTraceabilitySystem is Model, Event, ProductBase, ScoreBase {
    address admin;
    mapping(address => ProductionUnit) AddrToUnit;
    mapping(uint32 => ProductionUnit) IDToUnit;
    mapping(uint64 => User) IDToUser;
    mapping(uint64 => bool) registered;

    function generateProductID(uint32 _productionUnitID, uint16 _num)
        public
        override
        returns (bytes32[] memory IDs)
    {
        //IDs = new uint[](_num);
        for (uint16 i = 0; i < _num; i++) {
            IDs[i] = keccak256(
                abi.encodePacked(_productionUnitID, block.timestamp, i)
            );
            emit Confirm(IDs[i], _productionUnitID, 0, block.timestamp);
        }
    }

    function confirm(
        bytes32 _productionID,
        uint32 _productionUnitID,
        uint8 _state
    ) public override {
        require(AddrToUnit[msg.sender].ID == _productionUnitID);
        emit Confirm(_productionID, _productionUnitID, _state, block.timestamp);
    }

    function score(
        uint64 _userID,
        string calldata _password,
        uint32 _productionUnitID,
        uint8 _score
    ) public override {
        require(!IDToUser[_userID].banned);
        require(authCheck(_userID, _password));
        emit Score(_userID, _productionUnitID, block.timestamp, _score);
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

    function banUser(uint64 _userID) public {
        require(msg.sender == admin);
        IDToUser[_userID].banned = true;
        emit Ban(_userID, block.timestamp);
    }

    function sanction(uint32 _productionUnitID) public {
        require(msg.sender == admin);
        IDToUnit[_productionUnitID].banned = true;
        IDToUnit[_productionUnitID].score = 0;
        IDToUnit[_productionUnitID].power = 0;
        IDToUnit[_productionUnitID].scores = 0;
        emit Sanction(_productionUnitID, block.timestamp);
    }
    
    function unitRecover(uint32 _productionUnitID)public{
        require(msg.sender == admin);
        require(IDToUnit[_productionUnitID].banned == true);
        IDToUnit[_productionUnitID].banned = false;

    }

    function userRegister(uint64 _ID, string calldata _password) public {
        require(registered[_ID] == false);
        registered[_ID] = true;
        IDToUser[_ID] = User({password: _password, banned: false});
    }

    function authCheck(uint64 _ID, string calldata _password)
        internal
        view
        returns (bool)
    {
        require(registered[_ID] == true);
        string memory rightPass = IDToUser[_ID].password;

        if (bytes(_password).length != bytes(rightPass).length) {
            return false;
        }
        for (uint256 i = 0; i < bytes(_password).length; i++) {
            if (bytes(_password)[i] != bytes(rightPass)[i]) {
                return false;
            }
        }
        return true;
    }

    function unitRegister(uint32 _ID, string calldata _name) public {
        require(IDToUnit[_ID].ID == 0);
        IDToUnit[_ID] = ProductionUnit({
            ID: _ID,
            name: _name,
            banned: false,
            score: 0,
            power: 0,
            scores: 0
        });
    }
}
