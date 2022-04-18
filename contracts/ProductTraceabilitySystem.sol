pragma solidity ^0.8.0;
import "./ComplainQueue.sol";
import "./Event.sol";
import "./Model.sol";

contract ProductTraceabilitySystem is
    ComplainQueue,
    Event
{
    address admin;
    mapping(address => ProductionUnit) AddrToUnit;
    mapping(uint32 => ProductionUnit) IDToUnit;
    mapping(uint64 => User) IDToUser;
    mapping(address=>uint64) addressToID;
    mapping(uint64 => bool) registered;
    ComplainQueue complainQueue;

    function generateProductID(uint32 _productionUnitID, uint16 _num)
        public
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
    ) public {
        require(AddrToUnit[msg.sender].ID == _productionUnitID);
        emit Confirm(_productionID, _productionUnitID, _state, block.timestamp);
    }

    function score(
        uint32 _productionUnitID,
        uint8 _score
    ) public  {
        uint64 _userID=addressToID[msg.sender];
        require(!IDToUser[_userID].banned);
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

    function unitRecover(uint32 _productionUnitID) public {
        require(msg.sender == admin);
        require(IDToUnit[_productionUnitID].banned == true);
        IDToUnit[_productionUnitID].banned = false;
    }

    function userRegister(uint64 _ID) public {
        require(registered[_ID] == false);
        registered[_ID] = true;
        addressToID[msg.sender]=_ID;
        IDToUser[_ID] = User({ banned: false, credit: 2});
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

    function complain(
        string calldata _password,
        uint32 _productionUnitID,
        string calldata _msg
    ) public {
        require(!IDToUser[addressToID[msg.sender]].banned);
        emit Complaint(addressToID[msg.sender], _productionUnitID, block.timestamp, _msg);
        Complain memory _complain = Complain({
            userID: addressToID[msg.sender],
            productionUnitID: _productionUnitID,
            timeStamp: block.timestamp
        });
        push(complainQueue, _complain);
    }

    function getComplains()public view returns(Complain[] memory complains){
        require(msg.sender == admin);
        return complainQueue.data;
    }

    function HandleComplain(uint32 _productionUnitID, bool _result) public {
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
}
