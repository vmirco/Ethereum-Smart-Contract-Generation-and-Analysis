// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondCutFacet {
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    enum FacetCutAction { Add, Replace, Remove }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function to add, replace, or remove function selectors
    function _diamondCut(
        FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCut memory cut = _diamondCut[i];
            for (uint256 j = 0; j < cut.functionSelectors.length; j++) {
                bytes4 selector = cut.functionSelectors[j];
                if (cut.action == FacetCutAction.Add) {
                    // Add function
                    assembly {
                        sstore(selector, cut.facetAddress)
                    }
                } else if (cut.action == FacetCutAction.Replace) {
                    // Replace function
                    assembly {
                        sstore(selector, cut.facetAddress)
                    }
                } else if (cut.action == FacetCutAction.Remove) {
                    // Remove function
                    assembly {
                        sstore(selector, 0)
                    }
                }
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        _initializeDiamondCut(_init, _calldata);
    }

    // Internal function to execute initialization function using delegatecall
    function _initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "DiamondCutFacet: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length != 0, "DiamondCutFacet: _calldata is empty but _init is not address(0)");
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            require(success, string(error));
        }
    }

    // Fallback function to delegate calls to facets
    fallback() external payable {
        address facet = sload(msg.sig);
        require(facet != address(0), "DiamondCutFacet: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}