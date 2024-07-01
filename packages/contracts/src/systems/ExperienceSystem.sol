// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IWorld } from "../codegen/world/IWorld.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { Balances } from "@latticexyz/world/src/codegen/tables/Balances.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { Hook } from "@latticexyz/store/src/Hook.sol";
import { ICustomUnregisterDelegation } from "@latticexyz/world/src/ICustomUnregisterDelegation.sol";
import { IOptionalSystemHook } from "@latticexyz/world/src/IOptionalSystemHook.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { AccessControlLib } from "@latticexyz/world-modules/src/utils/AccessControlLib.sol";
import { IERC165 } from "@latticexyz/world/src/IERC165.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { ExperienceMetadata, ExperienceMetadataData } from "../codegen/tables/ExperienceMetadata.sol";
import { DisplayStatus } from "../codegen/tables/DisplayStatus.sol";
import { DisplayRegisterMsg } from "../codegen/tables/DisplayRegisterMsg.sol";
import { DisplayUnregisterMsg } from "../codegen/tables/DisplayUnregisterMsg.sol";
import { Notifications } from "../codegen/tables/Notifications.sol";
import { Players } from "../codegen/tables/Players.sol";
import { Areas, AreasData } from "../codegen/tables/Areas.sol";
import { Builds, BuildsData } from "../codegen/tables/Builds.sol";
import { BuildsWithPos, BuildsWithPosData } from "../codegen/tables/BuildsWithPos.sol";
import { Countdown } from "../codegen/tables/Countdown.sol";
import { Tokens } from "../codegen/tables/Tokens.sol";

import { VoxelCoord } from "@biomesaw/utils/src/Types.sol";
import { voxelCoordsAreEqual, inSurroundingCube } from "@biomesaw/utils/src/VoxelCoordUtils.sol";

// Available utils, remove the ones you don't need
// See ObjectTypeIds.sol for all available object types
import { PlayerObjectID, AirObjectID, DirtObjectID, ChestObjectID } from "@biomesaw/world/src/ObjectTypeIds.sol";
import { getBuildArgs, getMineArgs, getMoveArgs, getHitArgs, getDropArgs, getTransferArgs, getCraftArgs, getEquipArgs, getLoginArgs, getSpawnArgs } from "../utils/HookUtils.sol";
import { getSystemId, getNamespaceSystemId, isSystemId, callBuild, callMine, callMove, callHit, callDrop, callTransfer, callCraft, callEquip, callUnequip, callLogin, callLogout, callSpawn, callActivate } from "../utils/DelegationUtils.sol";
import { hasBeforeAndAfterSystemHook, hasDelegated, getObjectTypeAtCoord, getEntityAtCoord, getPosition, getObjectType, getMiningDifficulty, getStackable, getDamage, getDurability, isTool, isBlock, getEntityFromPlayer, getPlayerFromEntity, getEquipped, getHealth, getStamina, getIsLoggedOff, getLastHitTime, getInventoryTool, getInventoryObjects, getCount, getNumSlotsUsed, getNumUsesLeft } from "../utils/EntityUtils.sol";
import { Area, insideArea, insideAreaIgnoreY, getEntitiesInArea, getArea, setArea } from "../utils/AreaUtils.sol";
import { Build, BuildWithPos, buildExistsInWorld, buildWithPosExistsInWorld, getBuild, setBuild, getBuildWithPos, setBuildWithPos } from "../utils/BuildUtils.sol";
import { NamedArea, NamedBuild, NamedBuildWithPos, weiToString, getEmptyBlockOnGround } from "../utils/GameUtils.sol";

import { IExperienceSystem } from "../prototypes/IExperienceSystem.sol";
import { EXPERIENCE_NAMESPACE, DEATHMATCH_AREA_ID } from "../Constants.sol";
import { GameMetadata } from "../codegen/tables/GameMetadata.sol";
import { PlayerMetadata, PlayerMetadataData } from "../codegen/tables/PlayerMetadata.sol";
import { hasValidInventory, updatePlayersToDisplay, disqualifyPlayer } from "../Utils.sol";
import { LeaderboardEntry } from "../Types.sol";

// Functions that are called by EOAs
contract ExperienceSystem is IExperienceSystem {
  function joinExperience() public payable override {
    super.joinExperience();
    address player = _msgSender();

    require(!GameMetadata.getIsGameStarted(), "Game has already started.");
    bytes32 playerEntityId = getEntityFromPlayer(player);
    require(playerEntityId != bytes32(0), "You Must First Spawn An Avatar In Biome-1 To Play The Game");
    require(hasValidInventory(playerEntityId), "You can only have a maximum of 3 tools and 20 blocks");

    require(!PlayerMetadata.getIsRegistered(player), "Player is already registered");
    PlayerMetadata.setIsRegistered(player, true);
    PlayerMetadata.setIsAlive(player, true);
    GameMetadata.pushPlayers(player);
    updatePlayersToDisplay();

    Notifications.set(address(0), string.concat("Player ", Strings.toHexString(player), " has joined the game"));
  }

  function initExperience() public {
    AccessControlLib.requireOwner(SystemRegistry.get(address(this)), _msgSender());

    GameMetadata.setGameStarter(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    DisplayStatus.set("Waiting for the game to start");
    DisplayRegisterMsg.set(
      "Move hook, hit hook, and logoff hook prevent the player from moving outside match area, hitting players before match starts, or logging off during the match. Mine hook tracks kills from gravity."
    );
    DisplayUnregisterMsg.set("You will be disqualified if you unregister");

    address worldSystemAddress = Systems.getSystem(getNamespaceSystemId(EXPERIENCE_NAMESPACE, "WorldSystem"));
    require(worldSystemAddress != address(0), "WorldSystem not found");

    bytes32[] memory hookSystemIds = new bytes32[](4);
    hookSystemIds[0] = ResourceId.unwrap(getSystemId("MoveSystem"));
    hookSystemIds[1] = ResourceId.unwrap(getSystemId("HitSystem"));
    hookSystemIds[2] = ResourceId.unwrap(getSystemId("LogoffSystem"));
    hookSystemIds[3] = ResourceId.unwrap(getSystemId("MineSystem"));

    ExperienceMetadata.set(
      ExperienceMetadataData({
        contractAddress: worldSystemAddress,
        shouldDelegate: false,
        hookSystemIds: hookSystemIds,
        joinFee: 1400000000000000,
        name: "Deathmatch",
        description: "Stay inside the match area and kill as many players as you can! Most kills after 30 minutes gets reward pool."
      })
    );
  }

  function claimRewardPool() public {
    require(GameMetadata.getIsGameStarted(), "Game has not started yet.");
    require(block.number > Countdown.getCountdownEndBlock(), "Game has not ended yet.");
    address[] memory registeredPlayers = GameMetadata.getPlayers();
    if (registeredPlayers.length == 0) {
      resetGame(registeredPlayers);
      return;
    }

    uint256 maxKills = 0;
    for (uint i = 0; i < registeredPlayers.length; i++) {
      if (PlayerMetadata.getIsDisqualified(registeredPlayers[i])) {
        continue;
      }
      uint256 playerKills = PlayerMetadata.getNumKills(registeredPlayers[i]);
      if (playerKills > maxKills) {
        maxKills = playerKills;
      }
    }

    address[] memory playersWithMostKills = new address[](registeredPlayers.length);
    uint256 numPlayersWithMostKills = 0;
    for (uint i = 0; i < registeredPlayers.length; i++) {
      if (PlayerMetadata.getIsDisqualified(registeredPlayers[i])) {
        continue;
      }
      if (PlayerMetadata.getNumKills(registeredPlayers[i]) == maxKills) {
        playersWithMostKills[numPlayersWithMostKills] = registeredPlayers[i];
        numPlayersWithMostKills++;
      }
    }

    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(Utils.systemNamespace());
    uint256 rewardPool = Balances.get(namespaceId);
    if (numPlayersWithMostKills == 0 || rewardPool == 0) {
      resetGame(registeredPlayers);
      return;
    }

    // reset the game state
    resetGame(registeredPlayers);

    // Divide the reward pool among the players with the most kills
    uint256 rewardPerPlayer = rewardPool / numPlayersWithMostKills;
    for (uint i = 0; i < playersWithMostKills.length; i++) {
      if (playersWithMostKills[i] == address(0)) {
        continue;
      }
      IWorld(_world()).transferBalanceToAddress(namespaceId, playersWithMostKills[i], rewardPerPlayer);
    }
  }

  function resetGame(address[] memory registeredPlayers) internal {
    Notifications.set(address(0), "Game has ended. Reward pool has been distributed.");

    GameMetadata.setIsGameStarted(false);
    Countdown.setCountdownEndBlock(0);
    for (uint i = 0; i < registeredPlayers.length; i++) {
      PlayerMetadata.deleteRecord(registeredPlayers[i]);
    }
    GameMetadata.setPlayers(new address[](0));
    updatePlayersToDisplay();

    DisplayStatus.set("Waiting for the game to start");
  }

  function getKillsLeaderboard() public view returns (LeaderboardEntry[] memory) {
    address[] memory registeredPlayers = GameMetadata.getPlayers();
    LeaderboardEntry[] memory leaderboard = new LeaderboardEntry[](registeredPlayers.length);
    for (uint i = 0; i < registeredPlayers.length; i++) {
      if (PlayerMetadata.getIsDisqualified(registeredPlayers[i])) {
        continue;
      }
      leaderboard[i] = LeaderboardEntry({
        player: registeredPlayers[i],
        kills: PlayerMetadata.getNumKills(registeredPlayers[i]),
        isAlive: PlayerMetadata.getIsAlive(registeredPlayers[i])
      });
    }
    return leaderboard;
  }
}
