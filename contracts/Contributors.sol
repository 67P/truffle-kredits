pragma solidity ^0.4.18;

import './upgradeable/Upgradeable.sol';

contract Contributors is Upgradeable {

  struct Contributor {
    address account;
    bytes32 profileHash;
    uint8 hashFunction;
    uint8 hashSize;
    bool isCore;
    bool exists;
  }

  mapping (address => uint) public contributorIds;
  mapping (uint => Contributor) public contributors;
  uint256 public contributorsCount;

  event ContributorProfileUpdated(uint id, bytes32 oldProfileHash, bytes32 newProfileHash);
  event ContributorAddressUpdated(uint id, address oldAddress, address newAddress);
  event ContributorAdded(uint id, address _address);

  function initialize(address sender) public payable {
    require(msg.sender == address(registry));
    uint _id = 1;
    Contributor c = contributors[_id];
    c.exists = true;
    c.isCore = true;
    c.account = sender;
    contributorIds[sender] = _id;
    contributorsCount += 1;
  }

  function coreContributorsCount() constant public returns (uint) {
    uint count = 0;
    for (uint256 i = 1; i <= contributorsCount; i++) {
      if (contributors[i].isCore) {
        count += 1;
      }
    }
    return count;
  }

  function updateContributorAddress(uint _id, address _oldAddress, address _newAddress) public onlyRegistryContractFor('Operator') {
    contributorIds[_oldAddress] = 0;
    contributorIds[_newAddress] = _id;
    contributors[_id].account = _newAddress;
    ContributorAddressUpdated(_id, _oldAddress, _newAddress);
  }

  function updateContributorProfileHash(uint _id, uint8 _hashFunction, uint8 _hashSize, bytes32 _profileHash) public onlyRegistryContractFor('Operator') {
    Contributor c = contributors[_id];
    bytes32 _oldProfileHash = c.profileHash;
    c.profileHash = _profileHash;
    c.hashFunction = _hashFunction;
    c.hashSize = _hashSize;

    ContributorProfileUpdated(_id, _oldProfileHash, c.profileHash);
  }

  function addContributor(address _address, uint8 _hashFunction, uint8 _hashSize, bytes32 _profileHash, bool isCore) public onlyRegistryContractFor('Operator') {
    uint _id = contributorsCount + 1;
    if (contributors[_id].exists != true) {
      Contributor c = contributors[_id];
      c.exists = true;
      c.isCore = isCore;
      c.hashFunction = _hashFunction;
      c.hashSize = _hashSize;
      c.profileHash = _profileHash;
      c.account = _address;
      contributorIds[_address] = _id;

      contributorsCount += 1;

      ContributorAdded(_id, _address);
    }
  }

  function isCore(uint _id) constant public returns (bool) {
    return contributors[_id].isCore;
  }

  function exists(uint _id) constant public returns (bool) {
    return contributors[_id].exists;
  }

  function addressIsCore(address _address) constant public returns (bool) {
    return getContributorByAddress(_address).isCore;
  }

  function addressExists(address _address) constant public returns (bool) {
    return getContributorByAddress(_address).exists;
  }

  function getContributorIdByAddress(address _address) constant public returns (uint) {
    return contributorIds[_address];
  }

  function getContributorAddressById(uint _id) constant public returns (address) {
    return contributors[_id].account;
  }

  function getContributorByAddress(address _address) internal view returns (Contributor) {
    uint id = contributorIds[_address];
    return contributors[id];
  }
}
