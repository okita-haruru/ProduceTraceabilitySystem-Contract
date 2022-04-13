pragma solidity ^0.8.0;
import "./Model.sol";
contract ComplainQueue is Model
{
    struct ComplainQueue {
        Comlaint[] data;
        uint front;
        uint rear;
    }
 
    
    // push
    function push(ComplainQueue storage q, Comlaint storage data) internal
    {
        if ((q.rear + 1) % q.data.length == q.front)
           pop(q); // throw first;
        q.data[q.rear] = data;
        q.rear = (q.rear + 1) % q.data.length;
    }
    // pop
    function pop(ComplainQueue storage q) internal returns (Comlaint storage dat)
    {
        require(q.rear!=q.front);
        Comlaint storage r = q.data[q.front];
        dat=r;
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
}