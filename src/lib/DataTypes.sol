//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DataTypes {
    struct Video {
        uint256 views;
        uint256 likes;
        string[] comments;
        string category;
        string name;
        string description;
    }

    struct Channel {
        string channelName;
        bytes32[] videos;
        uint256 subscribers;
    }

    struct User {
        address[] subscribed;
        Video[] likedVideos;
    }
}