pragma solidity ^0.8.0;


import "./SignaturePerformanceTestVerifier.sol";

contract SignaturePerformanceTestWrappedVerifier {

    //SignaturePerformanceTestVerifier
    event VerifiedSignaturePerformanceTestVerifierEvent(address _verifier, bool result, uint[19] inputData);

    function wrappedTxVerifySignaturePerformanceTestVerifier(address _verifier, SignaturePerformanceTestVerifier.Proof memory proof, uint[19] memory inputData) public {
        bool result = SignaturePerformanceTestVerifier(_verifier).verifyTx(proof, inputData);
        emit VerifiedSignaturePerformanceTestVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyViewSignaturePerformanceTestVerifier(address _verifier, SignaturePerformanceTestVerifier.Proof memory proof, uint[19] memory inputData) public view returns(bool) {
        return SignaturePerformanceTestVerifier(_verifier).verifyTx(proof, inputData);
    }
}