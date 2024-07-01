// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { ExperienceMetadata, ExperienceMetadataData } from "../src/codegen/tables/ExperienceMetadata.sol";
import { DisplayStatus } from "../src/codegen/tables/DisplayStatus.sol";
import { DisplayRegisterMsg } from "../src/codegen/tables/DisplayRegisterMsg.sol";
import { DisplayUnregisterMsg } from "../src/codegen/tables/DisplayUnregisterMsg.sol";
import { Notifications } from "../src/codegen/tables/Notifications.sol";
import { Players } from "../src/codegen/tables/Players.sol";
import { Areas, AreasData } from "../src/codegen/tables/Areas.sol";
import { Builds, BuildsData } from "../src/codegen/tables/Builds.sol";
import { BuildsWithPos, BuildsWithPosData } from "../src/codegen/tables/BuildsWithPos.sol";
import { Countdown } from "../src/codegen/tables/Countdown.sol";
import { Tokens } from "../src/codegen/tables/Tokens.sol";

import { GameMetadata } from "../src/codegen/tables/GameMetadata.sol";
import { PlayerMetadata } from "../src/codegen/tables/PlayerMetadata.sol";

contract TestScript is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // IWorld(worldAddress).deathmatch__startGame(30);
    IWorld(worldAddress).deathmatch__claimRewardPool();
    address[] memory registeredPlayers = GameMetadata.getPlayers();
    for (uint i = 0; i < registeredPlayers.length; i++) {
      console.logAddress(registeredPlayers[i]);
      console.logUint(PlayerMetadata.getNumKills(registeredPlayers[i]));
    }

    vm.stopBroadcast();
  }
}
