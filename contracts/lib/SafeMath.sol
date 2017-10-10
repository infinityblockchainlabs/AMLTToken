pragma solidity ^0.4.11;

library SafeMath {

    /**
     * Add
     */
    function add(uint _a, uint _b)
        internal
        constant
        returns (uint)
    {
        uint c = _a + _b;
        assert(c >= _a && c >= _b);
        return c;
    }

    /**
     * Subtract
     */
    function sub(uint _a, uint _b)
        internal
        constant
        returns (uint)
    {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
     * Multiply
     */
    function mul(uint _a, uint _b)
        internal
        constant
        returns (uint)
    {
        uint c = _a * _b;
        assert(_a == 0 || c / _a == _b);
        return c;
    }

}