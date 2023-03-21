//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Events {
    event ChannelCreated(address channelOwner, string channelName);
    event ChannelDeleted(address channelOwner);
    event VideoDeleted(string name, string hash);
    event VideoUploaded(string hash, string name, string category);
    event NewSubscription(address channelAddress, address subscriber);
}