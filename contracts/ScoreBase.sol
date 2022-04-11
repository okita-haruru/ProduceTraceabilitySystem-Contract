pragma solidity ^0.8.0;


interface ScoreBase {
    function score(
        uint64 _userID,
        string calldata _password,
        uint32 _productionUnitID,
        uint8 _score
    ) external;

    //function updateScore(uint32 _productionUnitID)internal;

    function sanction(uint32 _productionUnitID) external;
}
