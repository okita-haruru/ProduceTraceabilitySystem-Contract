pragma solidity ^0.8.0;

contract Event {
    //state:
    //0:generated
    //1:producted
    //2:in
    //3:out
    event Confirm(bytes32 indexed productionID, uint32 indexed productionUnitID, uint8 state, uint32 timeStamp);
    event Score(bytes32 indexed userID, uint32 indexed productionUnitID, uint32 timeStamp);
    event Sanction(uint32 indexed productionUnitID, uint32 timeStamp);
    event Complaint(bytes32 indexed userID, uint32 indexed productionUnitID, uint32 timeStamp, string msg);
    event Warn(uint32 indexed productionUnitID, uint32 timeStamp);
}