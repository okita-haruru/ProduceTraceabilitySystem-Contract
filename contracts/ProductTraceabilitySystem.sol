pragma solidity ^0.8.0;
import "./ComplainQueue.sol";
import "./Event.sol";
import "./Model.sol";

contract ProductTraceabilitySystem is
    ComplainQueue,
    Event
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
    ComplainQueue complainQueue;

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
        require(!IDToUser[addressToUserID[msg.sender]].banned);
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
        IDToUser[_userID].banned = true;
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
        IDToUser[_ID] = User({ banned: false, credit: 2});
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
        require(!IDToUser[addressToUserID[msg.sender]].banned);
        emit Complaint(addressToUserID[msg.sender], _productionUnitID, block.timestamp, _msg);
        Complain memory _complain = Complain({
            userID: addressToUserID[msg.sender],
            productionUnitID: _productionUnitID,
            timeStamp: block.timestamp
        });
        push(complainQueue, _complain);
    }

    function getComplains()public view returns(Complain[] memory complains){
        require(!closed);
        require(msg.sender == admin);
        return complainQueue.data;
    }

    function HandleComplain(uint32 _productionUnitID, bool _result) public {
        require(!closed);
        require(msg.sender == admin);
        require(!IDToUser[getFirst(complainQueue).userID].banned);
        emit ComplaintHandled(_productionUnitID, block.timestamp, _result);
        Complain storage _complain = pop(complainQueue);
        if (!_result) {
            IDToUser[_complain.userID].credit--;
        } else {
            IDToUser[_complain.userID].credit++;
        }
    }
    function getNewUintID(uint32 _addrCode) internal view returns(uint32){
        return _addrCode<<12+registerCounter[_addrCode++];
    }
}
