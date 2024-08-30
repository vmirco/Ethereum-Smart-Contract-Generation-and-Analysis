pragma solidity ^0.8.0;

contract FacetBase {
    event DiamondCut(bytes[] _diamondCut, address[] _newFacets, bytes32 _selectorPositions);
}

struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}

contract Diamond {

    mapping(bytes4 => address) public facetAddress;
    mapping(address => Facet) public facet;
    bytes4[] functionSelectors;

    function diamondCut(Facet[] memory _facets) public {
        for(uint i = 0; i < _facets.length; i++) {
            facet[_facets[i].facetAddress] = _facets[i];
            for(uint j = 0; j < _facets[i].functionSelectors.length; j++) {
                facetAddress[_facets[i].functionSelectors[j]] = _facets[i].facetAddress;
                functionSelectors.push(_facets[i].functionSelectors[j]);
            }
        }
        emit DiamondCut(functionSelectors, _facets.facetAddress, bytes32(functionSelectors.length));
    }

    fallback() external payable {
        address targetFacetAddress = facetAddress[msg.sig];
        require(targetFacetAddress != address(0), "Function does not exist.");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), targetFacetAddress, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}