// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

struct LeaderboardEntry {
  address player;
  bool isAlive;
  uint256 kills;
}
