// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PlayerMetadata, PlayerMetadataData } from "./codegen/tables/PlayerMetadata.sol";
import { Players } from "./codegen/tables/Players.sol";

function removePlayer(address player) {
  PlayerMetadata.deleteRecord(player);

  address[] memory players = Players.get();
  address[] memory newPlayers = new address[](players.length - 1);
  uint256 newPlayersCount = 0;
  for (uint256 i = 0; i < players.length; i++) {
    if (players[i] != player) {
      newPlayers[newPlayersCount] = players[i];
      newPlayersCount++;
    }
  }
  Players.set(newPlayers);
}
