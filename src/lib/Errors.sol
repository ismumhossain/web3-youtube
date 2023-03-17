//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Errors {
    error CreateChannel();
    error ChannelAlreadyExist();
    error VideoDoesNotExist();
    error ChannelDoesNotExist();
    error YouAreNotChannelOwner();
    error VideoIsNotYours();
}