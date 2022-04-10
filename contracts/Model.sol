pragma solidity ^0.8.0;

interface Model {
    struct ProductionUnit {
        //address Addr;
        uint32 ID;
        bool banned;
        uint8 score;
        string name;
        address[] subAddr;
    }
    struct User {
        //bytes32 ID;
        bytes32 password;
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
