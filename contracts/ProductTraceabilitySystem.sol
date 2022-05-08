pragma solidity ^0.8.0;
import "./Event.sol";
import "./Model.sol";

contract ProductTraceabilitySystem is Event, Model {
    address admin;
    bool closed;
    mapping(uint32 => ProductionUnit) IDToUnit;
    mapping(bytes32 => User) IDToUser;
    mapping(address => uint32) addressToUnitID;
    mapping(address => bytes32) addressToUserID;
    mapping(bytes32 => bool) userRegistered;
    mapping(address => bool) unitRegistered;
    mapping(uint32 => uint16) registerCounter;

    constructor() {
        closed = false;
        admin = msg.sender;
    }

    function generateProductID(uint256 _time) public view returns (bytes32) {
        //require(!closed);
        // require(unitRegistered[msg.sender]);
        // require(!IDToUnit[addressToUnitID[msg.sender]].banned);

        bytes32 ID = keccak256(
            abi.encodePacked(addressToUnitID[msg.sender], _time)
        );
        return ID;
    }

    function confirm(bytes32 productionID, uint8 _state) public {
        require(!closed);
        require(!IDToUnit[addressToUnitID[msg.sender]].banned);
        //bytes32 _byteProductionID = stringToBytes32(_productionID);
        emit Confirm(
            productionID,
            addressToUnitID[msg.sender],
            _state,
            block.timestamp
        );
    }

    function stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function score(uint32 _productionUnitID, uint8 _score) public {
        require(!closed);
        require(IDToUser[addressToUserID[msg.sender]].credit > 0);
        emit Score(
            addressToUserID[msg.sender],
            _productionUnitID,
            block.timestamp,
            _score
        );
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

    function banUser(string calldata _ID) public {
        require(!closed);
        require(msg.sender == admin);
        bytes32 _userID = stringToBytes32(_ID);
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

    function userRecover(string calldata _ID) public {
        require(!closed);
        require(msg.sender == admin);
        bytes32 _userID = stringToBytes32(_ID);
        require(IDToUser[_userID].credit == 0);
        plusCredit(_userID);
    }

    function userRegister(string calldata _userID) public returns (bool) {
        bytes32 _ID = stringToBytes32(_userID);
        if (
            userRegistered[_ID] ||
            !(IDToUser[addressToUserID[msg.sender]].credit == 0)
        ) {
            return false;
        }

        userRegistered[_ID] = true;
        addressToUserID[msg.sender] = _ID;
        IDToUser[_ID] = User({ID: _ID, credit: 2});
        emit UserRegister(msg.sender, block.timestamp);
        return true;
    }

    function unitRegister(
        address _unitAddress,
        uint32 _addrCode,
        string calldata _name
    ) public returns (uint32) {
        require(!closed);
        require(msg.sender == admin);
        require(!unitRegistered[_unitAddress]);
        bytes32 name = stringToBytes32(_name);
        uint32 _ID = getNewUintID(_addrCode);
        addressToUnitID[_unitAddress] = _ID;
        IDToUnit[_ID] = ProductionUnit({
            ID: _ID,
            name: name,
            banned: false,
            score: 0,
            power: 0,
            scores: 0
        });
        return _ID;
        emit UnitRegister(_ID, block.timestamp);
    }

    function complain(uint32 _productionUnitID) public {
        require(!closed);
        require(IDToUser[addressToUserID[msg.sender]].credit > 0);
        emit Complaint(
            addressToUserID[msg.sender],
            _productionUnitID,
            block.timestamp
        );
    }

    function HandleComplain(
        string calldata _ID,
        uint32 _productionUnitID,
        uint8 _result
    ) public {
        require(!closed);
        require(msg.sender == admin);
        bytes32 _userID = stringToBytes32(_ID);
        if (_result == 1) {
            return;
        }
        if (_result == 0) {
            IDToUnit[_productionUnitID].banned = true;
            plusCredit(_userID);
        } else {
            minusCredit(_userID);
        }
        emit ComplaintHandled(_productionUnitID, block.timestamp, _result);
    }

    function getNewUintID(uint32 _addrCode) internal returns (uint32) {
        uint32 result = (_addrCode << 12) + registerCounter[_addrCode];
        registerCounter[_addrCode] += 1;
        return result;
    }

    function minusCredit(bytes32 _ID) internal {
        if (IDToUser[_ID].credit > 0) {
            IDToUser[_ID].credit--;
        }
    }

    function plusCredit(bytes32 _ID) internal {
        if (IDToUser[_ID].credit < 5) {
            IDToUser[_ID].credit++;
        }
    }

    function getScore(uint32 _unitID) public view returns (uint8) {
        return IDToUnit[_unitID].score;
    }

    function getCredit() public view returns (uint8) {
        //bytes32 _userID = stringToBytes32(_ID);
        // bytes32 _userID = stringToBytes32(_ID);
        return IDToUser[addressToUserID[msg.sender]].credit;
    }

    function getUserRegistered(address _address) public view returns (bool) {
        if (IDToUser[addressToUserID[msg.sender]].credit == 0) {
            return false;
        }
        return true;
    }

    function getUserID() public view returns (bytes32) {
        require(!closed);
        return addressToUserID[msg.sender];
    }

    function Bytes32ToString(bytes32 b32name)
        internal
        pure
        returns (string memory)
    {
        bytes memory bytesString = new bytes(32);

        // 定义一个变量记录字节数量
        uint256 charCount = 0;

        // 统计共有多少个字节数
        for (uint32 i = 0; i < 32; i++) {
            bytes1 char = bytes1(bytes32(uint256(b32name) * 2**(8 * i)));

            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }

        // 初始化一动态数组，长度为charCount
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }

        return string(bytesStringTrimmed);
    }

    function getUnitID() public view returns (uint32) {
        return addressToUnitID[msg.sender];
    }
}
