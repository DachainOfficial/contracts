// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract Registry is Initializable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    event InitializatedRegistry(string indexed registryName);

    event ContractCloned(
        address indexed contractTemplateAddress,
        address indexed newContractAddress
    );

    event SetContract(
        string indexed contractName,
        address indexed contractAddress
    );

    string version;
    string public name;
    mapping(string => address) private map;
    bool private _initialized = false;
    string registryURI;
    modifier initialized() {
        require(_initialized, "Dachain721:: contract is not initialized");
        _;
    }

    EnumerableSetUpgradeable.Bytes32Set keySet;

    function getContract(string memory key)
        external
        view
        initialized
        returns (address contractAddress)
    {
        return map[key];
    }

    function initialize(string memory registryName, string memory commitHash)
        public
        initializer
    {
        name = registryName;
        version = commitHash;
        __Ownable_init();
        _initialized = true;
        emit InitializatedRegistry(registryName);
    }

    function register(string memory key, address templateAddress)
        public
        initialized
        onlyOwner
        returns (address contractAddress)
    {
        require(map[key] == address(0), "Registry:: Contract already exists");
        require(
            templateAddress != address(0),
            "Registry:: Contract template cannot be void"
        );
        require(
            AddressUpgradeable.isContract(templateAddress),
            "Registry:: Contract template is not valid"
        );

        address clonedContractAddress = ClonesUpgradeable.clone(
            templateAddress
        );
        emit ContractCloned(templateAddress, clonedContractAddress);
        emit SetContract(key, clonedContractAddress);
        map[key] = clonedContractAddress;
        keySet.add(bytes32(bytes(key)));
        return templateAddress;
    }

    function setContract(string memory key, address addressValue)
        public
        initialized
        onlyOwner
    {
        require(map[key] == address(0), "Registry:: Contract already exists");
        require(
            addressValue != address(0),
            "Registry:: Contract value cannot be void"
        );
        require(
            AddressUpgradeable.isContract(addressValue),
            "Registry:: Contract value is not valid"
        );
        map[key] = addressValue;
        emit SetContract(key, addressValue);
        keySet.add(bytes32(bytes(key)));
    }

    function unSetContract(string memory key) public onlyOwner initialized {
        require(map[key] != address(0), "Registry:: Contract does not exist");
        map[key] = address(0);
        emit SetContract(key, address(0));
        keySet.remove(bytes32(bytes(key)));
    }

    function getVersion()
        public
        view
        virtual
        initialized
        returns (string memory)
    {
        return version;
    }

    function getContractCount()
        public
        view
        initialized
        returns (uint256 count)
    {
        return keySet.length();
    }

    function setRegistryURI(string memory URI) public initialized onlyOwner {
        registryURI = URI;
    }

    function getRegistryURI() public view initialized returns (string memory) {
        return registryURI;
    }

    function getContracts() public view initialized returns (bytes32[] memory) {
        return keySet.values();
    }
}
