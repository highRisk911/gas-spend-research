pragma solidity ^0.8.0;


import "./BasicAgeCheckImplementationPlusFieldVerifier.sol";

contract BasicAgeCheckImplementationPlusFieldWrappedVerifier {
    //BasicAgeCheckImplementationPlusFieldVerifier.sol

    event BasicAgeCheckImplementationPlusFieldVerifierEvent(address _verifier, bool result, uint[3] inputData);

    function wrappedTxVerifyBasicAgeCheckImplementationPlusFieldVerifier(address _verifier, BasicAgeCheckImplementationPlusFieldVerifier.Proof memory proof, uint[3] memory inputData) public {
        bool result = BasicAgeCheckImplementationPlusFieldVerifier(_verifier).verifyTx(proof, inputData);
        emit BasicAgeCheckImplementationPlusFieldVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyViewBasicAgeCheckImplementationPlusFieldVerifier(address _verifier, BasicAgeCheckImplementationPlusFieldVerifier.Proof memory proof, uint[3] memory inputData) public view returns(bool) {
        return BasicAgeCheckImplementationPlusFieldVerifier(_verifier).verifyTx(proof, inputData);
    }

}