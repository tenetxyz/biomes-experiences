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

import { PlayerMetadata, PlayerMetadataData } from "../codegen/tables/PlayerMetadata.sol";
import { removePlayer } from "../Utils.sol";

// Functions that are called by the Biomes World contract
contract WorldSystem is System, ICustomUnregisterDelegation, IOptionalSystemHook {
  function supportsInterface(bytes4 interfaceId) public pure override(IERC165, WorldContextConsumer) returns (bool) {
    return
      interfaceId == type(ICustomUnregisterDelegation).interfaceId ||
      interfaceId == type(IOptionalSystemHook).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function canUnregister(address delegator) public override returns (bool) {
    return true;
  }

  function onRegisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) public override {}

  function transferRemainingBalance(address player, uint256 balance, address recipient) internal {
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(Utils.systemNamespace());
    if (balance > 0) {
      if (recipient == address(0) || !PlayerMetadata.getIsRegistered(recipient)) {
        IWorld(_world()).transferBalanceToAddress(namespaceId, player, balance);
      } else {
        PlayerMetadata.setBalance(recipient, PlayerMetadata.getBalance(recipient) + balance);
      }
    }
  }

  function onUnregisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) public override {
    if (!PlayerMetadata.getIsRegistered(msgSender)) {
      return;
    }

    uint256 balance = PlayerMetadata.getBalance(msgSender);
    address recipient = PlayerMetadata.getLastHitter(msgSender);
    uint256 lastWithdrawalTime = PlayerMetadata.getLastWithdrawalTime(msgSender);
    removePlayer(msgSender);

    if (lastWithdrawalTime + 2 hours < block.timestamp) {
      ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(Utils.systemNamespace());
      IWorld(_world()).transferBalanceToAddress(namespaceId, msgSender, balance);
    } else {
      transferRemainingBalance(msgSender, balance, recipient);
    }
  }

  function onBeforeCallSystem(address msgSender, ResourceId systemId, bytes memory callData) public override {}

  function onAfterCallSystem(address msgSender, ResourceId systemId, bytes memory callData) public override {
    if (!PlayerMetadata.getIsRegistered(msgSender)) {
      return;
    }

    if (isSystemId(systemId, "LogoffSystem")) {
      require(false, "Cannot logoff when registered.");
      return;
    } else if (isSystemId(systemId, "SpawnSystem")) {
      uint256 playerBalance = PlayerMetadata.getBalance(msgSender);
      if (playerBalance == 0) {
        return;
      }
      address recipient = PlayerMetadata.getLastHitter(msgSender);

      removePlayer(msgSender);
      transferRemainingBalance(msgSender, playerBalance, recipient);
    } else if (isSystemId(systemId, "HitSystem")) {
      address hitPlayer = getHitArgs(callData);

      if (PlayerMetadata.getIsRegistered(hitPlayer)) {
        PlayerMetadata.setLastHitter(hitPlayer, msgSender);

        if (getEntityFromPlayer(hitPlayer) == bytes32(0)) {
          PlayerMetadata.setBalance(
            msgSender,
            PlayerMetadata.getBalance(msgSender) + PlayerMetadata.getBalance(hitPlayer)
          );
          removePlayer(hitPlayer);

          Notifications.set(
            address(0),
            string.concat(
              "Player ",
              Strings.toHexString(hitPlayer),
              " has been killed by ",
              Strings.toHexString(msgSender)
            )
          );
        }
      }
    }
  }
}
