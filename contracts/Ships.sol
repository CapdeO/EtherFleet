// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract EtherFleetShips is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /* ================ STATE VARIABLES ================ */

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    IERC20 etherFleetToken;
    uint256 public mintCost;
    uint256 public currentCardLimit;
    mapping(address => bool) public tokensSupported;
    uint256 private nonce;
    address public fundsReceiver;

    /* ================ EVENTS ================ */

    /* ================ CONSTRUCTOR ================ */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _tokenAddress,
        uint256 _cost,
        uint256 _initialCardLimit,
        address[] memory _initialTokenSupported,
        address _initialReceiver
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());

        etherFleetToken = IERC20(_tokenAddress);
        mintCost = _cost;
        currentCardLimit = _initialCardLimit;
        fundsReceiver = _initialReceiver;

        for (uint i = 0; i < _initialTokenSupported.length; i++) {
            tokensSupported[_initialTokenSupported[i]] = true;
        }
    }

    /* ================ CHANGE STATE ================ */

    function mint(address _stableToken, uint256 _amount) public {
        require(
            tokensSupported[_stableToken],
            "Stable token not supported for purchase."
        );

        uint256 _totalCost = mintCost * _amount;
        uint256 _rewardAmount = (_totalCost * 30) / 100;
        uint256 _decimals = IERC20Metadata(_stableToken).decimals();
        uint256 _adjustedCost = _totalCost / (10 ** (18 - _decimals));

        require(
            IERC20(_stableToken).transferFrom(
                _msgSender(),
                fundsReceiver,
                _adjustedCost
            )
        );

        require(
            etherFleetToken.balanceOf(address(this)) >= _rewardAmount,
            "Not enough EtherFleetToken for reward."
        );

        require(
            etherFleetToken.transfer(_msgSender(), _rewardAmount),
            "Reward transfer failed."
        );

        uint256[] memory _tokenIds = new uint256[](_amount);
        uint256[] memory _amounts = new uint256[](_amount);

        for (uint i = 0; i < _amount; i++) {
            _tokenIds[i] = getRandom();
            _amounts[i] = 1;
            nonce++;
        }

        _mintBatch(_msgSender(), _tokenIds, _amounts, "");
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    /* ================ VIEW ================ */

    function getRandom() public view returns (uint256) {
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    _msgSender(),
                    nonce
                )
            )
        ) % currentCardLimit;
        return random;
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
