//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Events {
    event ChannelCreated(address channelOwner, string channelName);
    event ChannelDeleted(address channelOwner, string channelName);
    event VideoDeleted(string name, bytes32 hash);
    event VideoUploaded(bytes32 hash, string name, string category);
    event NewSubscription(address channelAddress, address subscriber);
}