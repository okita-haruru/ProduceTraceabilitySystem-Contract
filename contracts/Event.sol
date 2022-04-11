pragma solidity ^0.8.0;

interface Event {
    //state:
    //0:generated
    //1:producted
    //2:in
    //3:out
    event Confirm(
        bytes32 indexed productionID,
        uint32 indexed productionUnitID,
        uint8 state,
        uint256 timeStamp
    );
    event Score(
        uint64 indexed userID,
        uint32 indexed productionUnitID,
        uint256 timeStamp,
        uint8 score
    );
    event Sanction(uint32 indexed productionUnitID, uint256 timeStamp);
    event Complaint(
        uint64 indexed userID,
        uint32 indexed productionUnitID,
        uint256 timeStamp,
        string msg
    );
    event Warn(uint32 indexed productionUnitID, uint256 timeStamp);
    event Ban(uint64 indexed userID, uint256 timeStamp);
}
