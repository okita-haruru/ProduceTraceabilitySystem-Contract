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
        //bytes32 ID;
        string password;
        bool banned;
    }
    // struct Product{
    //     bytes32 ID;
    //     string name;
    // }
    // struct Admin{
    //     address Addr;
    //     string name;
    // }
}
