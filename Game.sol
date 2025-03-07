// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./TimeUnit.sol";
import "./CommitReveal.sol";

contract RPS is CommitReveal {
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping(address => bytes32) public player_choice_hash;
    mapping(address => bool) public player_not_played;
    mapping(address => bool) public player_Valid;
    mapping(address => uint) public revealedChoices;
    address[] public players;
    uint public numInput = 0;
    address public owner;
    uint public startTime;
    uint public gameTimeout = 2 minutes;
    uint public waitingTime = 5 minutes;
    constructor() {
        owner = msg.sender;

        player_Valid[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = true;
        player_Valid[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = true;
        player_Valid[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = true;
        player_Valid[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = true;
    }

    function addPlayer() public payable {
        require(numPlayer < 2, "Only 2 players naa");
        require(player_Valid[msg.sender], "Invalid player");
        require(msg.value == 1 ether, "You need 1 ETH to play naja");

        if (numPlayer > 0) {
            require(msg.sender != players[0], "You are already added to the game jaa");
        }

        reward += msg.value;
        player_not_played[msg.sender] = true;
        players.push(msg.sender);
        numPlayer++;

        if (numPlayer == 2) {
            startTime = block.timestamp;
        }
    }

    function commitChoice(uint choice) public {
        require(numPlayer == 2, "Only 2 players naa");
        require(player_not_played[msg.sender], "You have already committed");
        require(choice >= 0 && choice <= 4, "Invalid choice ja");

        bytes32 commitment = keccak256(abi.encodePacked(choice));
        player_choice_hash[msg.sender] = commitment;
        player_not_played[msg.sender] = false;
        numInput++;
    }

    function revealChoice(uint choice) public {
        require(numInput == 2, "Both players must commit first");
        require(choice >= 0 && choice <= 4, "Invalid choice ja");
        require(keccak256(abi.encodePacked(choice)) == player_choice_hash[msg.sender], "Invalid reveal");

        revealedChoices[msg.sender] = choice;
        if (revealedChoices[players[0]] > 0 && revealedChoices[players[1]] > 0) {
            _checkWinnerAndPay();
        }
    }
    function checkWaitingTimeout() public {
        require(numPlayer == 1);
        if (block.timestamp >= startTime + waitingTime) {
            address payable player1 = payable(players[0]);
            player1.transfer(reward); 

            _resetGame();
        }
    }

    function checkTimeout() public {
        require(numPlayer == 2, "Only 2 players naa");
        if (block.timestamp >= startTime + gameTimeout && numInput < 2) {
            address payable account0 = payable(players[0]);
            address payable account1 = payable(players[1]);
            
            if (player_not_played[players[0]]) {
                account0.transfer(reward);
            }
            if (player_not_played[players[1]]) {
                account1.transfer(reward);
            }

            _resetGame();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = revealedChoices[players[0]];
        uint p1Choice = revealedChoices[players[1]];

        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);

        if ((p0Choice + 2) % 5 == p1Choice || (p0Choice + 4) % 5 == p1Choice) {
            account1.transfer(reward);
        } else if ((p1Choice + 2) % 5 == p0Choice || (p1Choice + 4) % 5 == p0Choice) {
            account0.transfer(reward);
        } else {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }

        _resetGame();
    }

    function _resetGame() private {
        numInput = 0;
        numPlayer = 0;
        reward = 0;
        delete players;
    }
}
