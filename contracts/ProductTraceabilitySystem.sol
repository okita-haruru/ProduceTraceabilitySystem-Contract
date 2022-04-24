pragma solidity ^0.8.0;
import "./Event.sol";
import "./Model.sol";

contract ProductTraceabilitySystem is  Event,Model
{
    address admin;
    bool closed;
    mapping(address => uint32) addressToUnitID;
    mapping(uint32 => ProductionUnit) IDToUnit;
    mapping(uint64 => User) IDToUser;
    mapping(address=>uint64) addressToUserID;
    mapping(uint64 => bool) userRegistered;
    mapping(address =>bool) unitRegistered;
    mapping(uint32=>uint16) registerCounter;

    constructor(){
        closed=false;
        admin=msg.sender;
    }

    function generateProductID(uint16 _num)
        public
        returns (bytes32[] memory IDs)
    {
        require(!closed);
        require(unitRegistered[msg.sender]);
        require(!IDToUnit[addressToUnitID[msg.sender]].banned);
        for (uint16 i = 0; i < _num; i++) {
            IDs[i] = keccak256(
                abi.encodePacked(addressToUnitID[msg.sender], block.timestamp, i)
            );
            emit Confirm(IDs[i],addressToUnitID[msg.sender], 0, block.timestamp);
        }
    }

    function confirm(
        bytes32 _productionID,
        uint8 _state
    ) public {
        require(!closed);
        require(!IDToUnit[addressToUnitID[msg.sender]].banned);
        emit Confirm(_productionID, addressToUnitID[msg.sender], _state, block.timestamp);
    }

    function score(
        uint32 _productionUnitID,
        uint8 _score
    ) public  {
        require(!closed);
        require(IDToUser[addressToUserID[msg.sender]].credit>0);
        emit Score(addressToUserID[msg.sender], _productionUnitID, block.timestamp, _score);
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
        require(!closed);
        require(msg.sender == admin);
        IDToUser[_userID].credit = 0;
        emit Ban(_userID, block.timestamp);
    }

    function sanction(uint32 _productionUnitID) public {
        require(!closed);
        require(msg.sender == admin);
        IDToUnit[_productionUnitID].banned = true;
        IDToUnit[_productionUnitID].score = 0;
        IDToUnit[_productionUnitID].power = 0;
        IDToUnit[_productionUnitID].scores = 0;
        emit Sanction(_productionUnitID, block.timestamp);
    }

    function unitRecover(uint32 _productionUnitID) public {
        require(!closed);
        require(msg.sender == admin);
        require(IDToUnit[_productionUnitID].banned == true);
        IDToUnit[_productionUnitID].banned = false;
    }

    function userRegister(uint64 _ID) public {
        require(userRegistered[_ID] == false);
        userRegistered[_ID] = true;
        addressToUserID[msg.sender]=_ID;
        IDToUser[_ID] = User({ ID: _ID, credit: 2});
    }

    function unitRegister(address _unitAddress,uint32 _addrCode, string calldata _name) public {
        require(!closed);
        require(msg.sender==admin);
        require(!unitRegistered[_unitAddress]);
        uint32 _ID=getNewUintID(_addrCode);
        addressToUnitID[_unitAddress]=_ID;
        IDToUnit[_ID] = ProductionUnit({
            ID: _ID,
            name: _name,
            banned: false,
            score: 0,
            power: 0,
            scores: 0
        });
    }

    function complain(
        uint32 _productionUnitID,
        string calldata _msg
    ) public {
        require(!closed);
        require(IDToUser[addressToUserID[msg.sender]].credit>0);
        emit Complaint(addressToUserID[msg.sender], _productionUnitID, block.timestamp, _msg);
    }

    function HandleComplain(uint64 _userID,uint32 _productionUnitID, uint8 _result) public {
        require(!closed);
        require(msg.sender == admin);
        if(_result==1)
        {
            return;
        }
        if(_result==0)
        {
            IDToUnit[_productionUnitID].banned=true;
            plusCredit(_userID);
        }else{
            minusCredit(_userID);
        }
    }
    function getNewUintID(uint32 _addrCode) internal view returns(uint32){
        return _addrCode<<12+registerCounter[_addrCode++];
    }

    function minusCredit(uint64 _userID) internal{
        if(IDToUser[_userID].credit>0)
        {
            IDToUser[_userID].credit--;
        }
    }
    function plusCredit(uint64 _userID) internal{
        if(IDToUser[_userID].credit<5)
        {
            IDToUser[_userID].credit++;
        }
    }
}
