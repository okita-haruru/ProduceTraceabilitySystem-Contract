pragma solidity ^0.8.0;

interface ProductBase {
    
    function generateProductID(
        uint32 _productionUnitID,
        uint16 _num
    ) external returns (bytes32[] memory IDs);

    function confirm(
        bytes32 _productionID,
        uint32 _productionUnitID,
        uint8 _state
    ) external;
}
