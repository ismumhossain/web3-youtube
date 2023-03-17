// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Web3Video.sol";

contract DeployNFT is Script {
    function run() public {
        vm.startBroadcast();
        new Web3Video();
        vm.stopBroadcast();
    }
}
