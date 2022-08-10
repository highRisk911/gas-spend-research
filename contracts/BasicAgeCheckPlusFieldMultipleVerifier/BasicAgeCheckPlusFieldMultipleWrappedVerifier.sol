pragma solidity ^0.8.0;


import "./BasicAgeCheckPlusFieldMultipleVerifier.sol";


contract BasicAgeCheckPlusFieldMultipleWrappedVerifier {
    //BasicAgeCheckPlusFieldMultipleVerifier

    event BasicAgeCheckPlusFieldMultipleVerifierEvent(address _verifier, bool result, uint[3] inputData);

    function wrappedTxVerifyBasicAgeCheckPlusFieldMultipleVerifier(address _verifier, BasicAgeCheckPlusFieldMultipleVerifier.Proof memory proof, uint[3] memory inputData) public {
        bool result = BasicAgeCheckPlusFieldMultipleVerifier(_verifier).verifyTx(proof, inputData);
        emit BasicAgeCheckPlusFieldMultipleVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyViewBasicAgeCheckPlusFieldMultipleVerifier(address _verifier, BasicAgeCheckPlusFieldMultipleVerifier.Proof memory proof, uint[3] memory inputData) public view returns(bool) {
        return BasicAgeCheckPlusFieldMultipleVerifier(_verifier).verifyTx(proof, inputData);
    }

}