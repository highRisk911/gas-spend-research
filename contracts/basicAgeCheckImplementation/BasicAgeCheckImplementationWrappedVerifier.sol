pragma solidity ^0.8.0;


import "./BasicAgeCheckImplementationVerifier.sol";


contract BasicAgeCheckImplementationWrappedVerifier {
    //BasicAgeCheckImplementationVerifier.sol


    event BasicAgeCheckImplementationEvent(address _verifier, bool result, uint[2] inputData);

    function wrappedTxVerifyBasicAgeCheckImplementation(address _verifier, BasicAgeCheckImplementationVerifier.Proof memory proof, uint[2] memory inputData) public {
        bool result = BasicAgeCheckImplementationVerifier(_verifier).verifyTx(proof, inputData);
        emit BasicAgeCheckImplementationEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyViewBasicAgeCheckImplementation(address _verifier, BasicAgeCheckImplementationVerifier.Proof memory proof, uint[2] memory inputData) public view returns(bool) {
        return BasicAgeCheckImplementationVerifier(_verifier).verifyTx(proof, inputData);
    }
}