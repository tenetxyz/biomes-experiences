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
import { EXPERIENCE_NAMESPACE } from "../Constants.sol";

import { IProcGenSystem } from "@biomesaw/world/src/codegen/world/IProcGenSystem.sol";

import { Builder } from "../codegen/tables/Builder.sol";
import { BuildMetadata, BuildMetadataData } from "../codegen/tables/BuildMetadata.sol";
import { PlayerMetadata } from "../codegen/tables/PlayerMetadata.sol";
import { BuildIds } from "../codegen/tables/BuildIds.sol";

// Functions that are called by EOAs
contract ChallengeSystem is System {
  function challengeBuilding(uint256 buildingId, uint256 n) public {
    require(buildingId <= BuildIds.get(), "Invalid building ID");
    require(bytes(Builds.getName(bytes32(buildingId))).length > 0, "Invalid building ID");

    Build memory blueprint = getBuild(bytes32(buildingId));
    BuildMetadataData memory buildMetadata = BuildMetadata.get(bytes32(buildingId));
    require(buildMetadata.submissionPrice > 0, "Build Metadata not found");
    require(n < buildMetadata.locationsX.length, "Invalid index");

    VoxelCoord memory baseWorldCoord = VoxelCoord({
      x: buildMetadata.locationsX[n],
      y: buildMetadata.locationsY[n],
      z: buildMetadata.locationsZ[n]
    });

    bool doesMatch = true;

    // Go through each relative position, apply it to the base world coord, and check if the object type id matches
    for (uint256 i = 0; i < blueprint.objectTypeIds.length; i++) {
      VoxelCoord memory absolutePosition = VoxelCoord({
        x: baseWorldCoord.x + blueprint.relativePositions[i].x,
        y: baseWorldCoord.y + blueprint.relativePositions[i].y,
        z: baseWorldCoord.z + blueprint.relativePositions[i].z
      });
      bytes32 entityId = getEntityAtCoord(absolutePosition);

      uint8 objectTypeId;
      if (entityId == bytes32(0)) {
        // then it's the terrain
        objectTypeId = IProcGenSystem(_world()).getTerrainBlock(absolutePosition);
      } else {
        objectTypeId = getObjectType(entityId);
      }
      if (objectTypeId != blueprint.objectTypeIds[i]) {
        doesMatch = false;
        break;
      }
    }

    if (!doesMatch) {
      address[] memory newBuilders = new address[](buildMetadata.builders.length - 1);
      int16[] memory newLocationsX = new int16[](buildMetadata.locationsX.length - 1);
      int16[] memory newLocationsY = new int16[](buildMetadata.locationsY.length - 1);
      int16[] memory newLocationsZ = new int16[](buildMetadata.locationsZ.length - 1);

      for (uint i = 0; i < buildMetadata.builders.length; i++) {
        if (i < n) {
          newBuilders[i] = buildMetadata.builders[i];
          newLocationsX[i] = buildMetadata.locationsX[i];
          newLocationsY[i] = buildMetadata.locationsY[i];
          newLocationsZ[i] = buildMetadata.locationsZ[i];
        } else if (i > n) {
          newBuilders[i - 1] = buildMetadata.builders[i];
          newLocationsX[i - 1] = buildMetadata.locationsX[i];
          newLocationsY[i - 1] = buildMetadata.locationsY[i];
          newLocationsZ[i - 1] = buildMetadata.locationsZ[i];
        }
      }

      BuildMetadata.setBuilders(bytes32(buildingId), newBuilders);
      BuildMetadata.setLocationsX(bytes32(buildingId), newLocationsX);
      BuildMetadata.setLocationsY(bytes32(buildingId), newLocationsY);
      BuildMetadata.setLocationsZ(bytes32(buildingId), newLocationsZ);
    }
  }
}
