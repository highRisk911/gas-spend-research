pragma solidity ^0.8.0;


import "./AgeCheckWithThreeNestedForVerifier.sol";

contract AgeCheckWithThreeNestedForWrappedVerifier {
    //AgeCheckWithThreeNestedForVerifier.sol
    event AgeCheckWithThreeNestedForVerifierEvent(address _verifier, bool result, uint[1002] inputData);

    function wrappedTxVerify___AgeCheckWithThreeNestedForVerifier(address _verifier, AgeCheckWithThreeNestedForVerifier.Proof memory proof, uint[1002] memory inputData) public {
        bool result = AgeCheckWithThreeNestedForVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithThreeNestedForVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithThreeNestedForVerifier(address _verifier, AgeCheckWithThreeNestedForVerifier.Proof memory proof, uint[1002] memory inputData) public view returns(bool) {
        return AgeCheckWithThreeNestedForVerifier(_verifier).verifyTx(proof, inputData);
    }
}