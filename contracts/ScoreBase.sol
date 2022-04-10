pragma solidity ^0.8.0;


interface ScoreBase {
    function score(
        bytes32 _userID,
        uint32 _productionUnitID,
        uint32 _timeStamp,
        uint8 _score
    ) external;

    function updateScore(uint32 _productionUnitID)external;

    function sanction(uint32 _productionUnitID, uint32 _timeStamp) external;
}
