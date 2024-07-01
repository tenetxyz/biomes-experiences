// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IWorld } from "../codegen/world/IWorld.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { System } from "@latticexyz/world/src/System.sol";
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

import { GameMetadata } from "../codegen/tables/GameMetadata.sol";
import { PlayerMetadata, PlayerMetadataData } from "../codegen/tables/PlayerMetadata.sol";
import { DEATHMATCH_AREA_ID } from "../Constants.sol";
import { updatePlayersToDisplay, disqualifyPlayer } from "../Utils.sol";

// Functions that are called by the Biomes World contract
contract WorldSystem is System, IOptionalSystemHook {
  function supportsInterface(bytes4 interfaceId) public pure override(IERC165, WorldContextConsumer) returns (bool) {
    return interfaceId == type(IOptionalSystemHook).interfaceId || super.supportsInterface(interfaceId);
  }

  function onRegisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) public override {}

  function onUnregisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) public override {
    disqualifyPlayer(msgSender);
  }

  function onBeforeCallSystem(address msgSender, ResourceId systemId, bytes memory callData) public override {}

  function onAfterCallSystem(address msgSender, ResourceId systemId, bytes memory callData) public override {
    PlayerMetadataData memory playerMetadata = PlayerMetadata.get(msgSender);
    if (!playerMetadata.isRegistered) {
      return;
    }
    bool isAlive = playerMetadata.isAlive;
    bool isGameStarted = GameMetadata.getIsGameStarted();
    uint256 gameEndBlock = Countdown.getCountdownEndBlock();
    if (isSystemId(systemId, "LogoffSystem")) {
      require(!isGameStarted || block.number > gameEndBlock, "Cannot logoff during the game");
      return;
    } else if (isSystemId(systemId, "HitSystem")) {
      if (isGameStarted && block.number > gameEndBlock) {
        return;
      }
      if (isGameStarted && isAlive) {
        (uint256 numNewDeadPlayers, bool msgSenderDied) = updateAlivePlayers(msgSender);
        if (msgSenderDied) {
          numNewDeadPlayers -= 1;
        }
        PlayerMetadata.setNumKills(msgSender, PlayerMetadata.getNumKills(msgSender) + numNewDeadPlayers);
      } else {
        address hitPlayer = getHitArgs(callData);
        PlayerMetadataData memory hitPlayerMetadata = PlayerMetadata.get(hitPlayer);
        require(
          !hitPlayerMetadata.isRegistered || !hitPlayerMetadata.isAlive || hitPlayerMetadata.isDisqualified,
          "Cannot hit game players before the game starts or if you died."
        );
      }
    } else if (isSystemId(systemId, "MineSystem")) {
      if (!isGameStarted || !isAlive || block.number > gameEndBlock) {
        return;
      }
      (uint256 numNewDeadPlayers, bool msgSenderDied) = updateAlivePlayers(msgSender);
      if (msgSenderDied) {
        numNewDeadPlayers -= 1;
      }
      PlayerMetadata.setNumKills(msgSender, PlayerMetadata.getNumKills(msgSender) + numNewDeadPlayers);
    } else if (isSystemId(systemId, "MoveSystem")) {
      if (!isGameStarted || block.number > gameEndBlock) {
        return;
      }

      Area memory matchArea = getArea(DEATHMATCH_AREA_ID);

      VoxelCoord memory playerPosition = getPosition(getEntityFromPlayer(msgSender));
      if (isAlive) {
        require(
          insideAreaIgnoreY(matchArea, playerPosition),
          "Cannot move outside the match area while the game is running"
        );
      } else {
        require(
          !insideAreaIgnoreY(matchArea, playerPosition),
          "Cannot move inside the match area while the game is running and you are dead."
        );
      }
    }
  }

  function updateAlivePlayers(address msgSender) internal returns (uint256, bool) {
    address[] memory registeredPlayers = GameMetadata.getPlayers();
    uint256 numNewDeadPlayers = 0;
    bool msgSenderDied = false;
    for (uint i = 0; i < registeredPlayers.length; i++) {
      address player = registeredPlayers[i];
      if (!PlayerMetadata.getIsAlive(player) || PlayerMetadata.getIsDisqualified(player)) {
        continue;
      }
      bytes32 playerEntity = getEntityFromPlayer(player);
      if (playerEntity == bytes32(0)) {
        numNewDeadPlayers++;
        if (player == msgSender) {
          msgSenderDied = true;
        }
        PlayerMetadata.setIsAlive(player, false);
        Notifications.set(address(0), string.concat("Player ", Strings.toHexString(player), " has died"));
      }
    }

    if (numNewDeadPlayers > 0) {
      updatePlayersToDisplay();
    }

    return (numNewDeadPlayers, msgSenderDied);
  }
}
