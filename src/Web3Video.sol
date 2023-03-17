//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DataTypes} from "./lib/DataTypes.sol";
import {Errors} from "./lib/Errors.sol";
import {Events} from "./lib/Events.sol";

contract Web3Video {

    mapping(bytes32 => DataTypes.Video) private videos;
    mapping(address => DataTypes.Channel) private channels;
    mapping(address => DataTypes.User) private users;

    function createChannel(string memory nameOfChannel) external {
        if(channelExist(msg.sender)) {
            revert Errors.ChannelAlreadyExist();
        }
        channels[msg.sender] = DataTypes.Channel(nameOfChannel, new bytes32[](0), 0);
        emit Events.ChannelCreated(msg.sender, nameOfChannel);
    }

    function deleteChannel() external {
        DataTypes.Channel memory channel = channels[msg.sender];
        if(!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        delete(channel);
        emit Events.ChannelDeleted(msg.sender, channel.channelName);
    }

    function deleteVideo(uint256 index,string memory name, string memory category, bytes32 hash) external {
        if(!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        if(!videoExistOnChannel(index, name, category, hash)) {
            revert Errors.VideoIsNotYours();
        }
        if(!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        delete videos[hash];
        bytes32[] storage _videos = channels[msg.sender].videos;
        require(index < _videos.length);
        delete _videos[index];
        _videos[index] = _videos[_videos.length - 1];
        _videos.pop();
        emit Events.VideoDeleted(name, hash);
    }

    function uploadVideo(bytes32 hash, string memory category, string memory name, string memory description) external {
        if(!channelExist(msg.sender)) {
            revert Errors.CreateChannel();
        }
        videos[hash] = DataTypes.Video(0, 0, new string[](0), category, name, description);
        DataTypes.Channel storage channel = channels[msg.sender];
        channel.videos.push(hash);
        emit Events.VideoUploaded(hash, name, category);
    }

    function countView(bytes32 hash) external {
        if(!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        DataTypes.Video storage _video = videos[hash];
        _video.views += 1;
    }

    function likeVideo(bytes32 hash) external {
        if(!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        DataTypes.Video storage _video = videos[hash];
        _video.likes += 1;
        DataTypes.User storage user = users[msg.sender];
        user.likedVideos.push(videos[hash]);
    }

    function comment(bytes32 hash, string memory newComment) external {
        if(!videoExist(hash)) {
            revert Errors.VideoDoesNotExist();
        }
        DataTypes.Video storage _video = videos[hash];
        _video.comments.push(newComment);
    }

    function subscribe(address channelOwner) external {
        if(!channelExist(channelOwner)) {
            revert Errors.ChannelDoesNotExist();
        }
        DataTypes.Channel storage channel = channels[channelOwner];
        channel.subscribers += 1;
        DataTypes.User storage user = users[msg.sender];
        user.subscribed.push(channelOwner);
        emit Events.NewSubscription(channelOwner, msg.sender);
    }

    function channelExist(address channelOwner) internal view returns(bool) {
        string memory nameOfChannel = channels[channelOwner].channelName;
        if(bytes(nameOfChannel).length != 0) {
            return true;
        }
        return false;
    }

    function videoExist(bytes32 hash) internal view returns(bool) {
        string memory nameOfVideo = videos[hash].name;
        if(bytes(nameOfVideo).length != 0) {
            return true;
        }
        return false;
    }

    function videoExistOnChannel(uint256 index, string memory name, string memory category, bytes32 hash) internal view returns(bool) {
        DataTypes.Channel memory channel = channels[msg.sender];
        DataTypes.Video memory video = videos[hash];
        if(index >= channel.videos.length) {
            return false;
        }
        if(keccak256(abi.encodePacked(video.name, video.category)) == keccak256(abi.encodePacked(name, category))) {
            return true;
        }
        return false;
    }

    function seeVideos(bytes32 hash) external view returns(DataTypes.Video memory) {
        return videos[hash];
    }

    function seeChannels(address channelOwner) external view returns(DataTypes.Channel memory) {
        return channels[channelOwner];
    }

    function seeProfile(address user) external view returns(DataTypes.User memory) {
        return users[user];
    }
}