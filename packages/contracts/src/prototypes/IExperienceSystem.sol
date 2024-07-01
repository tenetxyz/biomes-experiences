// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

abstract contract IExperienceSystem is System {
  function onRegister() public payable virtual;
}