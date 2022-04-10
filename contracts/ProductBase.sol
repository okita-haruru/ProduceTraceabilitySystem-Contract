pragma solidity ^0.8.0;

interface ProductBase {
    
    function generateProductID(
        uint32 _productionUnitID,
        uint32 _timeStamp,
        uint16 _num
    ) external returns (bytes32[] memory IDs);
    // {
    //     //IDs = new uint[](_num);
    //     for (uint16 i = 0; i < _num; i++) {
    //         IDs[i] = keccak256(
    //             abi.encodePacked(_productionUnitID, _timeStamp, i)
    //         );
    //         emit Confirm(IDs[i], _productionUnitID, 0, _timeStamp);
    //     }
    // }

    function confirm(
        bytes32 _productionID,
        uint32 _timeStamp,
        uint32 _productionUnitID,
        uint8 _state
    ) external;
    // {
    //     emit Confirm(_productionID, _productionUnitID, _state, _timeStamp);
    // }


}
