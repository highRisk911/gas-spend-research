pragma solidity ^0.8.0;


import "./EmptyCircuitVerifier.sol";

contract EmptyCircuitWrappedVerifier {



    //EmptyCircuitVerifier
    event EmptyCircuitVerifierEvent(address _verifier, bool result);

    function wrappedTxVerifyEmptyCircuitVerifier(address _verifier, EmptyCircuitVerifier.Proof memory proof) public {
        bool result = EmptyCircuitVerifier(_verifier).verifyTx(proof);
        emit EmptyCircuitVerifierEvent(_verifier, result);

    }

    function wrappedTxVerifyViewEmptyCircuitVerifier(address _verifier, EmptyCircuitVerifier.Proof memory proof) public view returns(bool) {
        return EmptyCircuitVerifier(_verifier).verifyTx(proof);
    }
}