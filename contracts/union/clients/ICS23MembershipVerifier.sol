// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "../lib/ICS23.sol";
import "../lib/UnionICS23.sol";

library ICS23MembershipVerifier {
    function verifyMembership(
        bytes32 root,
        bytes calldata proof,
        bytes memory prefix,
        bytes calldata path,
        bytes calldata value
    ) internal pure returns (bool) {
        UnionIcs23.ExistenceProof[2] calldata existenceProof;
        assembly {
            existenceProof := proof.offset
        }
        return Ics23.verifyChainedMembership(
            existenceProof, root, prefix, path, value
        ) == Ics23.VerifyChainedMembershipError.None;
    }

    struct NonMembershipProof {
        UnionIcs23.NonExistenceProof nonexist;
        UnionIcs23.ExistenceProof exist;
    }

    function verifyNonMembership(
        bytes32 root,
        bytes calldata proof,
        bytes memory prefix,
        bytes calldata path
    ) internal pure returns (bool) {
        NonMembershipProof calldata nonexistenceProof;
        assembly {
            nonexistenceProof := proof.offset
        }
        return Ics23.verifyChainedNonMembership(
            nonexistenceProof.nonexist,
            nonexistenceProof.exist,
            root,
            prefix,
            path
        ) == Ics23.VerifyChainedNonMembershipError.None;
    }
}
