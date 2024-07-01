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
contract ExperienceSystem is IExperienceSystem {
  function joinExperience() public payable override {
    super.joinExperience();
  }

  function initExperience() public {
    AccessControlLib.requireOwner(SystemRegistry.get(address(this)), _msgSender());

    DisplayStatus.set(
      "Join Monument Chains: Build One Yourself, Reward existing builders, and earn from future builders."
    );

    address worldSystemAddress = Systems.getSystem(getNamespaceSystemId(EXPERIENCE_NAMESPACE, "WorldSystem"));
    require(worldSystemAddress != address(0), "WorldSystem not found");

    bytes32[] memory hookSystemIds = new bytes32[](1);
    hookSystemIds[0] = ResourceId.unwrap(getSystemId("BuildSystem"));

    ExperienceMetadata.set(
      ExperienceMetadataData({
        contractAddress: worldSystemAddress,
        shouldDelegate: false,
        hookSystemIds: hookSystemIds,
        joinFee: 0,
        name: "Build A Nomics",
        description: "Join Monument Chains: Build One Yourself, Reward existing builders, and earn from future builders."
      })
    );
  }

  function create(Build memory blueprint, uint256 submissionPrice, string memory name) public {
    require(blueprint.objectTypeIds.length > 0, "Must specify at least one object type ID.");
    require(
      blueprint.objectTypeIds.length == blueprint.relativePositions.length,
      "Number of object type IDs must match number of relative position."
    );
    require(
      voxelCoordsAreEqual(blueprint.relativePositions[0], VoxelCoord({ x: 0, y: 0, z: 0 })),
      "First relative position must be (0, 0, 0)."
    );
    require(bytes(name).length > 0, "Must specify a name.");
    require(submissionPrice > 0, "Must specify a submission price.");

    uint256 newBuildId = BuildIds.get() + 1;
    BuildIds.set(newBuildId);

    BuildMetadata.set(
      bytes32(newBuildId),
      BuildMetadataData({
        submissionPrice: submissionPrice,
        builders: new address[](0),
        locationsX: new int16[](0),
        locationsY: new int16[](0),
        locationsZ: new int16[](0)
      })
    );

    setBuild(bytes32(newBuildId), name, blueprint);

    Notifications.set(address(0), "A new build has been added to the game.");
  }

  function submitBuilding(uint256 buildingId, VoxelCoord memory baseWorldCoord) public payable {
    require(buildingId <= BuildIds.get(), "Invalid building ID");
    require(bytes(Builds.getName(bytes32(buildingId))).length > 0, "Invalid building ID");

    Build memory blueprint = getBuild(bytes32(buildingId));
    BuildMetadataData memory buildMetadata = BuildMetadata.get(bytes32(buildingId));
    require(buildMetadata.submissionPrice > 0, "Build Metadata not found");
    VoxelCoord[] memory existingBuildLocations = new VoxelCoord[](buildMetadata.locationsX.length);
    for (uint i = 0; i < buildMetadata.locationsX.length; i++) {
      existingBuildLocations[i] = VoxelCoord({
        x: buildMetadata.locationsX[i],
        y: buildMetadata.locationsY[i],
        z: buildMetadata.locationsZ[i]
      });
    }

    address msgSender = _msgSender();
    require(_msgValue() == buildMetadata.submissionPrice, "Incorrect submission price.");

    for (uint i = 0; i < existingBuildLocations.length; ++i) {
      if (voxelCoordsAreEqual(existingBuildLocations[i], baseWorldCoord)) {
        revert("Location already exists");
      }
    }

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

        address builder = Builder.get(absolutePosition.x, absolutePosition.y, absolutePosition.z);
        require(builder == msgSender, "Builder does not match");
      }
      if (objectTypeId != blueprint.objectTypeIds[i]) {
        revert("Build does not match.");
      }
    }

    uint256 numBuilders = buildMetadata.builders.length;
    {
      address[] memory newBuilders = new address[](buildMetadata.builders.length + 1);
      for (uint i = 0; i < buildMetadata.builders.length; i++) {
        newBuilders[i] = buildMetadata.builders[i];
      }
      newBuilders[buildMetadata.builders.length] = msgSender;

      int16[] memory newLocationsX = new int16[](buildMetadata.locationsX.length + 1);
      int16[] memory newLocationsY = new int16[](buildMetadata.locationsY.length + 1);
      int16[] memory newLocationsZ = new int16[](buildMetadata.locationsZ.length + 1);
      for (uint i = 0; i < buildMetadata.locationsX.length; i++) {
        newLocationsX[i] = buildMetadata.locationsX[i];
        newLocationsY[i] = buildMetadata.locationsY[i];
        newLocationsZ[i] = buildMetadata.locationsZ[i];
      }
      newLocationsX[buildMetadata.locationsX.length] = baseWorldCoord.x;
      newLocationsY[buildMetadata.locationsY.length] = baseWorldCoord.y;
      newLocationsZ[buildMetadata.locationsZ.length] = baseWorldCoord.z;

      BuildMetadata.setBuilders(bytes32(buildingId), newBuilders);
      BuildMetadata.setLocationsX(bytes32(buildingId), newLocationsX);
      BuildMetadata.setLocationsY(bytes32(buildingId), newLocationsY);
      BuildMetadata.setLocationsZ(bytes32(buildingId), newLocationsZ);
    }

    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(Utils.systemNamespace());
    if (numBuilders > 0) {
      uint256 splitAmount = _msgValue() / numBuilders;
      uint256 totalDistributed = splitAmount * numBuilders;
      uint256 remainder = _msgValue() - totalDistributed;

      for (uint256 i = 0; i < numBuilders; i++) {
        PlayerMetadata.setEarned(
          buildMetadata.builders[i],
          PlayerMetadata.getEarned(buildMetadata.builders[i]) + splitAmount
        );

        Notifications.set(buildMetadata.builders[i], "You've earned some ether for your contribution to a build.");

        IWorld(_world()).transferBalanceToAddress(namespaceId, buildMetadata.builders[i], splitAmount);
      }

      if (remainder > 0) {
        IWorld(_world()).transferBalanceToAddress(namespaceId, msgSender, remainder);
      }
    } else {
      PlayerMetadata.setEarned(msgSender, PlayerMetadata.getEarned(msgSender) + _msgValue());

      IWorld(_world()).transferBalanceToAddress(namespaceId, msgSender, _msgValue());
    }
  }
}
