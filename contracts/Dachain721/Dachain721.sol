// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract Dachain721 is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable,
    ERC721EnumerableUpgradeable,
    MulticallUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    event InitializatedDachain721(
        string indexed name,
        uint256 indexed maxSupply,
        string indexed version
    );

    event ContractCloned(
        address indexed contractTemplateAddress,
        address indexed newContractAddress
    );

    CountersUpgradeable.Counter tokenIDCounter;
    uint256 maxCurrentSupply;
    string baseURI;
    string version;
    bool private _initialized = false;

    modifier initialized() {
        require(_initialized, "Dachain721:: contract is not initialized");
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        string memory baseTokenURI,
        string memory commitHash
    ) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init();
        __Multicall_init();
        baseURI = baseTokenURI;
        maxCurrentSupply = maxSupply;
        _initialized = true;
        version = commitHash;
        emit InitializatedDachain721(name, maxSupply, version);
    }

    function getTokenMintCount()
        public
        view
        initialized
        returns (uint256 tokenCount)
    {
        return tokenIDCounter.current();
    }

    function mint(address to)
        external
        onlyOwner
        initialized
        returns (uint256 tokenId)
    {
        require(
            tokenIDCounter.current() < maxCurrentSupply,
            "Dachain721:: Max minted supply reached"
        );
        super._safeMint(to, tokenIDCounter.current());
        tokenIDCounter.increment();
        return tokenIDCounter.current();
    }

    function burn(uint256 tokenId) external initialized {
        require(
            ownerOf(tokenId) == _msgSender(),
            "Dachain721:: Only owner is allowed to burn tokens"
        );
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable)
        initialized
        returns (string memory uriString)
    {
        require(_exists(tokenId), "Dachain721:: URI set of nonexistent token");
        return baseURI;
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

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
