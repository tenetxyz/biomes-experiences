// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

/**
 * @title IWorldSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IWorldSystem {
  function buildanomics__supportsInterface(bytes4 interfaceId) external pure returns (bool);

  function buildanomics__onRegisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) external;

  function buildanomics__onUnregisterHook(
    address msgSender,
    ResourceId systemId,
    uint8 enabledHooksBitmap,
    bytes32 callDataHash
  ) external;

  function buildanomics__onBeforeCallSystem(address msgSender, ResourceId systemId, bytes memory callData) external;

  function buildanomics__onAfterCallSystem(address msgSender, ResourceId systemId, bytes memory callData) external;
}
