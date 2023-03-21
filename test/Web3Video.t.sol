//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Web3Video.sol";

contract TestCreateChannel is Test {
    Web3Video public web3Video;

    event ChannelCreated(address channelOwner, string channelName);

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_CreateChannel() public {
        string memory name = "IHossain";
        web3Video.createChannel(name);
        assertEq(web3Video.channelExist(address(this)), true);
    }

    function test_reverts() public {
        string memory name = "IHossain";
        web3Video.createChannel(name);
        vm.expectRevert(bytes4(keccak256("ChannelAlreadyExist()")));
        web3Video.createChannel(name);
    }

    function test_emitsEvent() public {
        string memory name = "IHossain";
        vm.expectEmit(true, true, true, true);
        emit ChannelCreated(address(this), name);
        web3Video.createChannel(name);
    }
}

contract TestDeleteChannel is Test {
    Web3Video public web3Video;

    event ChannelDeleted(address channelOwner);

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_reverts() public {
        vm.expectRevert(bytes4(keccak256("CreateChannel()")));
        web3Video.deleteChannel();
    }

    function test_emitEvent() public {
        string memory name = "IHossain";
        web3Video.createChannel(name);
        vm.expectEmit(true, true, true, true);
        emit ChannelDeleted(address(this));
        web3Video.deleteChannel();
    }

    function test_deletesChannel() public {
        string memory name = "IHossain";
        web3Video.createChannel(name);
        web3Video.deleteChannel();
        assertEq(web3Video.channelExist(address(this)), false);
    }
}

contract TestUpload is Test {
    Web3Video public web3Video;

    event VideoUploaded(string hash, string name, string category);

    string public constant hash = "QmTAznyH583xUgEyY5zdrPB2LSGY7FUBPDddWKj58GmBgp";
    string public constant category = "Tech Video";
    string public constant name = "How I made 1 million in 1 year with my MacBook Pro.";
    string public constant description =
        "This is a video about my income. It will show you that how you can also earn a lot of money with your MacBook.";

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_revertsIfNotChannel() public {
        vm.expectRevert(bytes4(keccak256("CreateChannel()")));
        web3Video.uploadVideo(hash, category, name, description);
    }

    function test_uploadsVideo() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        assertEq(web3Video.videoExist(hash), true);
    }

    function test_updatesChannel() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        string memory video = web3Video.seeChannels(address(this)).videos[0];
        assertEq(video, hash);
    }

    function test_emitEventUpload() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        vm.expectEmit(true, true, true, true);
        emit VideoUploaded(hash, name, category);
        web3Video.uploadVideo(hash, category, name, description);
    }
}

contract TestDelete is Test {
    Web3Video public web3Video;

    event VideoDeleted(string name, string hash);

    string public constant hash = "QmTAznyH583xUgEyY5zdrPB2LSGY7FUBPDddWKj58GmBgp";
    string public constant category = "Tech Video";
    string public constant name = "How I made 1 million in 1 year with my MacBook Pro.";
    string public constant description =
        "This is a video about my income. It will show you that how you can also earn a lot of money with your MacBook.";
    uint256 index = 0;

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_revertsCreate() public {
        vm.expectRevert(bytes4(keccak256("CreateChannel()")));
        web3Video.deleteVideo(index, name, hash);
    }

    function test_revertsVideoExist() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        vm.expectRevert(bytes4(keccak256("VideoDoesNotExist()")));
        web3Video.deleteVideo(index, name, hash);
    }

    function test_deletesVideo() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        web3Video.deleteVideo(index, name, hash);
        assertEq(web3Video.videoExist(hash), false);
    }

    function test_deleteFromChannel() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        web3Video.deleteVideo(index, name, hash);
        assertEq(web3Video.videoExistOnChannel(index, name, category, hash), false);
    }

    function test_videoDeletedEvent() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        vm.expectEmit(true, true, true, true);
        emit VideoDeleted(name, hash);
        web3Video.deleteVideo(index, name, hash);
    }
}

contract TestCountView is Test {
    Web3Video public web3Video;

    string public constant hash = "QmTAznyH583xUgEyY5zdrPB2LSGY7FUBPDddWKj58GmBgp";
    string public constant category = "Tech Video";
    string public constant name = "How I made 1 million in 1 year with my MacBook Pro.";
    string public constant description =
        "This is a video about my income. It will show you that how you can also earn a lot of money with your MacBook.";

    function setUp() public {
        web3Video = new Web3Video();
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
    }

    function test_countView() public {
        web3Video.countView(hash);
        uint256 videoViews = web3Video.seeVideos(hash).views;
        assertEq(videoViews, 1);
    }
}

contract TestLikeVideo is Test {
    Web3Video public web3Video;

    string public constant hash = "QmTAznyH583xUgEyY5zdrPB2LSGY7FUBPDddWKj58GmBgp";
    string public constant category = "Tech Video";
    string public constant name = "How I made 1 million in 1 year with my MacBook Pro.";
    string public constant description =
        "This is a video about my income. It will show you that how you can also earn a lot of money with your MacBook.";

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_revertsIfNotExist() public {
        vm.expectRevert(bytes4(keccak256("VideoDoesNotExist()")));
        web3Video.likeVideo(hash);
    }

    function test_updatesLike() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        web3Video.likeVideo(hash);
        assertEq(web3Video.seeVideos(hash).likes, 1);
    }

    function test_updatesUser() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        web3Video.likeVideo(hash);
        uint256 length = web3Video.seeProfile(address(this)).likedVideos.length;
        assertEq(length, 1);
    }
}

contract TestComment is Test {
    Web3Video public web3Video;

    string public constant hash = "QmTAznyH583xUgEyY5zdrPB2LSGY7FUBPDddWKj58GmBgp";
    string public constant category = "Tech Video";
    string public constant name = "How I made 1 million in 1 year with my MacBook Pro.";
    string public constant description =
        "This is a video about my income. It will show you that how you can also earn a lot of money with your MacBook.";
    string newComment = "The video is really good";

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_revertsIfVideoNotExist() public {
        vm.expectRevert(bytes4(keccak256("VideoDoesNotExist()")));
        web3Video.comment(hash, newComment);
    }

    function test_addComments() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.uploadVideo(hash, category, name, description);
        web3Video.comment(hash, newComment);
        uint256 length = web3Video.seeVideos(hash).comments.length;
        assertEq(length, 1);
    }
}

contract TestSubscribe is Test {
    Web3Video public web3Video;

    event NewSubscription(address channelAddress, address subscriber);

    function setUp() public {
        web3Video = new Web3Video();
    }

    function test_revertsIfChannelNotExist() public {
        vm.expectRevert(bytes4(keccak256("ChannelDoesNotExist()")));
        web3Video.subscribe(address(this));
    }

    function test_updatesSubscribers() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.subscribe(address(this));
        assertEq(web3Video.seeChannels(address(this)).subscribers, 1);
    }

    function test_updatesSubscribedUser() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        web3Video.subscribe(address(this));
        uint256 length = web3Video.seeProfile(address(this)).subscribed.length;
        assertEq(length, 1);
    }

    function test_emitSubscriptionEvent() public {
        string memory channelName = "IHossain";
        web3Video.createChannel(channelName);
        vm.expectEmit(true, true, true, true);
        emit NewSubscription(address(this), address(this));
        web3Video.subscribe(address(this));
    }
}
