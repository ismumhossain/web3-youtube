//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Errors} from "./lib/Errors.sol";
import {Events} from "./lib/Events.sol";

contract Web3Video {
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
        string[] videos;
        uint256 subscribers;
    }

    struct User {
        address[] subscribed;
        string[] likedVideos;
    }

    mapping(string => Video) private videos;
    mapping(address => Channel) private channels;
    mapping(address => User) private users;

    function createChannel(string memory nameOfChannel) external {
        if (channelExist(msg.sender)) {
            revert Errors.ChannelAlreadyExist();
        }
        channels[msg.sender] = Channel(nameOfChannel, new string[](0), 0);
        emit Events.ChannelCreated(msg.sender, nameOfChannel);
    }

    function deleteChannel() external {
        if (!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        delete (channels[msg.sender]);
        emit Events.ChannelDeleted(msg.sender);
    }

    function uploadVideo(
        string memory hash,
        string memory category,
        string memory name,
        string memory description
    ) external {
        if (!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        videos[hash] = Video(0, 0, new string[](0), category, name, description);
        Channel storage channel = channels[msg.sender];
        channel.videos.push(hash);
        emit Events.VideoUploaded(hash, name, category);
    }

    function deleteVideo(uint256 index, string memory name, string memory hash) external {
        if (!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        if (!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        delete videos[hash];
        string[] storage _videos = channels[msg.sender].videos;
        require(index < _videos.length);
        _videos[index] = _videos[_videos.length - 1];
        _videos.pop();
        emit Events.VideoDeleted(name, hash);
    }

    function countView(string memory hash) external {
        if (!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        Video storage _video = videos[hash];
        _video.views += 1;
    }

    function likeVideo(string memory hash) external {
        if (!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        Video storage _video = videos[hash];
        _video.likes += 1;
        User storage user = users[msg.sender];
        user.likedVideos.push(hash);
    }

    function comment(string memory hash, string memory newComment) external {
        if (!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        Video storage _video = videos[hash];
        _video.comments.push(newComment);
    }

    function subscribe(address channelOwner) external {
        if (!channelExist(channelOwner)) {
            revert Errors.ChannelDoesNotExist();
        }
        Channel storage channel = channels[channelOwner];
        channel.subscribers += 1;
        User storage user = users[msg.sender];
        user.subscribed.push(channelOwner);
        emit Events.NewSubscription(channelOwner, msg.sender);
    }

    function channelExist(address channelOwner) public view returns (bool) {
        string memory nameOfChannel = channels[channelOwner].channelName;
        if (bytes(nameOfChannel).length != 0) {
            return true;
        }
        return false;
    }

    function videoExist(string memory hash) public view returns (bool) {
        string memory nameOfVideo = videos[hash].name;
        if (bytes(nameOfVideo).length != 0) {
            return true;
        }
        return false;
    }

    function videoExistOnChannel(
        uint256 index,
        string memory name,
        string memory category,
        string memory hash
    ) public view returns (bool) {
        Channel memory channel = channels[msg.sender];
        Video memory video = videos[hash];
        if (index >= channel.videos.length) {
            return false;
        }
        if (
            keccak256(abi.encodePacked(video.name, video.category)) ==
            keccak256(abi.encodePacked(name, category))
        ) {
            return true;
        }
        return false;
    }

    function seeVideos(string memory hash) external view returns (Video memory) {
        return videos[hash];
    }

    function seeChannels(address channelOwner) external view returns (Channel memory) {
        return channels[channelOwner];
    }

    function seeProfile(address user) external view returns (User memory) {
        return users[user];
    }
}
