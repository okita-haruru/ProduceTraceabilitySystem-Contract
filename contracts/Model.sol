pragma solidity ^0.8.0;

interface Model {
    struct ProductionUnit {
        uint32 ID;
        bool banned;
        uint8 score;
        string name;
        uint16 power;
        uint64 scores;
    }
    struct User {
        uint64 ID;
        uint8 credit;
    }
    struct Complain {
        uint64 userID;
        uint32 productionUnitID;
        uint256 timeStamp;
    }
    
}
