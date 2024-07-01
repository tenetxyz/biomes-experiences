// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

struct BuildsData {
  string name;
  uint8[] objectTypeIds;
  int16[] relativePositionsX;
  int16[] relativePositionsY;
  int16[] relativePositionsZ;
}

library Builds {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "deathmatch", name: "Builds", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x746264656174686d61746368000000004275696c647300000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0000000500000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (string, uint8[], int16[], int16[], int16[])
  Schema constant _valueSchema = Schema.wrap(0x00000005c5628383830000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "id";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](5);
    fieldNames[0] = "name";
    fieldNames[1] = "objectTypeIds";
    fieldNames[2] = "relativePositionsX";
    fieldNames[3] = "relativePositionsY";
    fieldNames[4] = "relativePositionsZ";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get name.
   */
  function getName(bytes32 id) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (string(_blob));
  }

  /**
   * @notice Get name.
   */
  function _getName(bytes32 id) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (string(_blob));
  }

  /**
   * @notice Set name.
   */
  function setName(bytes32 id, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, bytes((name)));
  }

  /**
   * @notice Set name.
   */
  function _setName(bytes32 id, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, bytes((name)));
  }

  /**
   * @notice Get the length of name.
   */
  function lengthName(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get the length of name.
   */
  function _lengthName(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get an item of name.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemName(bytes32 id, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /**
   * @notice Get an item of name.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemName(bytes32 id, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /**
   * @notice Push a slice to name.
   */
  function pushName(bytes32 id, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, bytes((_slice)));
  }

  /**
   * @notice Push a slice to name.
   */
  function _pushName(bytes32 id, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, bytes((_slice)));
  }

  /**
   * @notice Pop a slice from name.
   */
  function popName(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 1);
  }

  /**
   * @notice Pop a slice from name.
   */
  function _popName(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 1);
  }

  /**
   * @notice Update a slice of name at `_index`.
   */
  function updateName(bytes32 id, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = bytes((_slice));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update a slice of name at `_index`.
   */
  function _updateName(bytes32 id, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = bytes((_slice));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get objectTypeIds.
   */
  function getObjectTypeIds(bytes32 id) internal view returns (uint8[] memory objectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /**
   * @notice Get objectTypeIds.
   */
  function _getObjectTypeIds(bytes32 id) internal view returns (uint8[] memory objectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /**
   * @notice Set objectTypeIds.
   */
  function setObjectTypeIds(bytes32 id, uint8[] memory objectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((objectTypeIds)));
  }

  /**
   * @notice Set objectTypeIds.
   */
  function _setObjectTypeIds(bytes32 id, uint8[] memory objectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((objectTypeIds)));
  }

  /**
   * @notice Get the length of objectTypeIds.
   */
  function lengthObjectTypeIds(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get the length of objectTypeIds.
   */
  function _lengthObjectTypeIds(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get an item of objectTypeIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemObjectTypeIds(bytes32 id, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 1, (_index + 1) * 1);
      return (uint8(bytes1(_blob)));
    }
  }

  /**
   * @notice Get an item of objectTypeIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemObjectTypeIds(bytes32 id, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 1, (_index + 1) * 1);
      return (uint8(bytes1(_blob)));
    }
  }

  /**
   * @notice Push an element to objectTypeIds.
   */
  function pushObjectTypeIds(bytes32 id, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to objectTypeIds.
   */
  function _pushObjectTypeIds(bytes32 id, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from objectTypeIds.
   */
  function popObjectTypeIds(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 1, 1);
  }

  /**
   * @notice Pop an element from objectTypeIds.
   */
  function _popObjectTypeIds(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 1, 1);
  }

  /**
   * @notice Update an element of objectTypeIds at `_index`.
   */
  function updateObjectTypeIds(bytes32 id, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of objectTypeIds at `_index`.
   */
  function _updateObjectTypeIds(bytes32 id, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get relativePositionsX.
   */
  function getRelativePositionsX(bytes32 id) internal view returns (int16[] memory relativePositionsX) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 2);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Get relativePositionsX.
   */
  function _getRelativePositionsX(bytes32 id) internal view returns (int16[] memory relativePositionsX) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 2);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Set relativePositionsX.
   */
  function setRelativePositionsX(bytes32 id, int16[] memory relativePositionsX) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 2, EncodeArray.encode((relativePositionsX)));
  }

  /**
   * @notice Set relativePositionsX.
   */
  function _setRelativePositionsX(bytes32 id, int16[] memory relativePositionsX) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 2, EncodeArray.encode((relativePositionsX)));
  }

  /**
   * @notice Get the length of relativePositionsX.
   */
  function lengthRelativePositionsX(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 2);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of relativePositionsX.
   */
  function _lengthRelativePositionsX(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 2);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of relativePositionsX.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsX(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 2, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsX.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsX(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 2, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsX.
   */
  function pushRelativePositionsX(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 2, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsX.
   */
  function _pushRelativePositionsX(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 2, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsX.
   */
  function popRelativePositionsX(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 2, 2);
  }

  /**
   * @notice Pop an element from relativePositionsX.
   */
  function _popRelativePositionsX(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 2, 2);
  }

  /**
   * @notice Update an element of relativePositionsX at `_index`.
   */
  function updateRelativePositionsX(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 2, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsX at `_index`.
   */
  function _updateRelativePositionsX(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 2, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get relativePositionsY.
   */
  function getRelativePositionsY(bytes32 id) internal view returns (int16[] memory relativePositionsY) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 3);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Get relativePositionsY.
   */
  function _getRelativePositionsY(bytes32 id) internal view returns (int16[] memory relativePositionsY) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 3);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Set relativePositionsY.
   */
  function setRelativePositionsY(bytes32 id, int16[] memory relativePositionsY) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 3, EncodeArray.encode((relativePositionsY)));
  }

  /**
   * @notice Set relativePositionsY.
   */
  function _setRelativePositionsY(bytes32 id, int16[] memory relativePositionsY) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 3, EncodeArray.encode((relativePositionsY)));
  }

  /**
   * @notice Get the length of relativePositionsY.
   */
  function lengthRelativePositionsY(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 3);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of relativePositionsY.
   */
  function _lengthRelativePositionsY(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 3);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of relativePositionsY.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsY(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 3, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsY.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsY(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 3, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsY.
   */
  function pushRelativePositionsY(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 3, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsY.
   */
  function _pushRelativePositionsY(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 3, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsY.
   */
  function popRelativePositionsY(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 3, 2);
  }

  /**
   * @notice Pop an element from relativePositionsY.
   */
  function _popRelativePositionsY(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 3, 2);
  }

  /**
   * @notice Update an element of relativePositionsY at `_index`.
   */
  function updateRelativePositionsY(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 3, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsY at `_index`.
   */
  function _updateRelativePositionsY(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 3, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get relativePositionsZ.
   */
  function getRelativePositionsZ(bytes32 id) internal view returns (int16[] memory relativePositionsZ) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 4);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Get relativePositionsZ.
   */
  function _getRelativePositionsZ(bytes32 id) internal view returns (int16[] memory relativePositionsZ) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 4);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int16());
  }

  /**
   * @notice Set relativePositionsZ.
   */
  function setRelativePositionsZ(bytes32 id, int16[] memory relativePositionsZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 4, EncodeArray.encode((relativePositionsZ)));
  }

  /**
   * @notice Set relativePositionsZ.
   */
  function _setRelativePositionsZ(bytes32 id, int16[] memory relativePositionsZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 4, EncodeArray.encode((relativePositionsZ)));
  }

  /**
   * @notice Get the length of relativePositionsZ.
   */
  function lengthRelativePositionsZ(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 4);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of relativePositionsZ.
   */
  function _lengthRelativePositionsZ(bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 4);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of relativePositionsZ.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsZ(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 4, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsZ.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsZ(bytes32 id, uint256 _index) internal view returns (int16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 4, _index * 2, (_index + 1) * 2);
      return (int16(uint16(bytes2(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsZ.
   */
  function pushRelativePositionsZ(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 4, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsZ.
   */
  function _pushRelativePositionsZ(bytes32 id, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 4, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsZ.
   */
  function popRelativePositionsZ(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 4, 2);
  }

  /**
   * @notice Pop an element from relativePositionsZ.
   */
  function _popRelativePositionsZ(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 4, 2);
  }

  /**
   * @notice Update an element of relativePositionsZ at `_index`.
   */
  function updateRelativePositionsZ(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 4, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsZ at `_index`.
   */
  function _updateRelativePositionsZ(bytes32 id, uint256 _index, int16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 4, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get the full data.
   */
  function get(bytes32 id) internal view returns (BuildsData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(bytes32 id) internal view returns (BuildsData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(
    bytes32 id,
    string memory name,
    uint8[] memory objectTypeIds,
    int16[] memory relativePositionsX,
    int16[] memory relativePositionsY,
    int16[] memory relativePositionsZ
  ) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    bytes32 id,
    string memory name,
    uint8[] memory objectTypeIds,
    int16[] memory relativePositionsX,
    int16[] memory relativePositionsY,
    int16[] memory relativePositionsZ
  ) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(bytes32 id, BuildsData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      _table.name,
      _table.objectTypeIds,
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      _table.name,
      _table.objectTypeIds,
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(bytes32 id, BuildsData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      _table.name,
      _table.objectTypeIds,
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      _table.name,
      _table.objectTypeIds,
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    EncodedLengths _encodedLengths,
    bytes memory _blob
  )
    internal
    pure
    returns (
      string memory name,
      uint8[] memory objectTypeIds,
      int16[] memory relativePositionsX,
      int16[] memory relativePositionsY,
      int16[] memory relativePositionsZ
    )
  {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(1);
    }
    objectTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint8());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(2);
    }
    relativePositionsX = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int16());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(3);
    }
    relativePositionsY = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int16());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(4);
    }
    relativePositionsZ = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int16());
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   *
   * @param _encodedLengths Encoded lengths of dynamic fields.
   * @param _dynamicData Tightly packed dynamic fields.
   */
  function decode(
    bytes memory,
    EncodedLengths _encodedLengths,
    bytes memory _dynamicData
  ) internal pure returns (BuildsData memory _table) {
    (
      _table.name,
      _table.objectTypeIds,
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    ) = decodeDynamic(_encodedLengths, _dynamicData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(
    string memory name,
    uint8[] memory objectTypeIds,
    int16[] memory relativePositionsX,
    int16[] memory relativePositionsY,
    int16[] memory relativePositionsZ
  ) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(
        bytes(name).length,
        objectTypeIds.length * 1,
        relativePositionsX.length * 2,
        relativePositionsY.length * 2,
        relativePositionsZ.length * 2
      );
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(
    string memory name,
    uint8[] memory objectTypeIds,
    int16[] memory relativePositionsX,
    int16[] memory relativePositionsY,
    int16[] memory relativePositionsZ
  ) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        bytes((name)),
        EncodeArray.encode((objectTypeIds)),
        EncodeArray.encode((relativePositionsX)),
        EncodeArray.encode((relativePositionsY)),
        EncodeArray.encode((relativePositionsZ))
      );
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    string memory name,
    uint8[] memory objectTypeIds,
    int16[] memory relativePositionsX,
    int16[] memory relativePositionsY,
    int16[] memory relativePositionsZ
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      name,
      objectTypeIds,
      relativePositionsX,
      relativePositionsY,
      relativePositionsZ
    );

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(bytes32 id) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = id;

    return _keyTuple;
  }
}
