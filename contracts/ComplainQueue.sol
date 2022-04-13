pragma solidity ^0.8.0;
import "./Model.sol";

contract ComplainQueue is Model {
    struct ComplainQueue {
        Complain[] data;
        uint256 front;
        uint256 rear;
    }

    // push
    function push(ComplainQueue storage q, Complain memory data) internal {
        if ((q.rear + 1) % q.data.length == q.front) pop(q); // throw first;
        q.data[q.rear] = data;
        q.rear = (q.rear + 1) % q.data.length;
    }

    // pop
    function pop(ComplainQueue storage q)
        internal
        returns (Complain storage dat)
    {
        require(q.rear != q.front);
        Complain storage r = q.data[q.front];
        dat = r;
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }

    function getFirst(ComplainQueue storage q)
        internal
        view
        returns (Complain storage dat)
    {
        require(q.rear != q.front);
        Complain storage r = q.data[q.front];
        dat = r;
    }
}
