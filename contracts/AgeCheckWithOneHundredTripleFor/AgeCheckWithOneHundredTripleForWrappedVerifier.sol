pragma solidity ^0.8.0;



import "./AgeCheckWithOneHundredTripleForVerifier.sol";

contract AgeCheckWithOneHundredTripleForWrappedVerifier {
    //AgeCheckWithOneHundredTripleForVerifier.sol

    event AgeCheckWithOneHundredTripleForVerifierEvent(address _verifier, bool result, uint[102] inputData);

    function wrappedTxVerify___AgeCheckWithOneHundredTripleForVerifier(address _verifier, AgeCheckWithOneHundredTripleForVerifier.Proof memory proof, uint[102] memory inputData) public {
        bool result = AgeCheckWithOneHundredTripleForVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneHundredTripleForVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneHundredTripleForVerifier(address _verifier, AgeCheckWithOneHundredTripleForVerifier.Proof memory proof, uint[102] memory inputData) public view returns(bool) {
        return AgeCheckWithOneHundredTripleForVerifier(_verifier).verifyTx(proof, inputData);
    }
}