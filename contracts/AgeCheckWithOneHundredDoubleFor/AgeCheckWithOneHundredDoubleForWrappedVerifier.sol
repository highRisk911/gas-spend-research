pragma solidity ^0.8.0;


import "./AgeCheckWithOneHundredDoubleForVerifier.sol";

contract AgeCheckWithOneHundredDoubleForWrappedVerifier {

    //AgeCheckWithOneHundredDoubleForVerifier.sol

    event AgeCheckWithOneHundredDoubleForVerifierEvent(address _verifier, bool result, uint[102] inputData);

    function wrappedTxVerify___AgeCheckWithOneHundredDoubleForVerifier(address _verifier, AgeCheckWithOneHundredDoubleForVerifier.Proof memory proof, uint[102] memory inputData) public {
        bool result = AgeCheckWithOneHundredDoubleForVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneHundredDoubleForVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneHundredDoubleForVerifier(address _verifier, AgeCheckWithOneHundredDoubleForVerifier.Proof memory proof, uint[102] memory inputData) public view returns(bool) {
        return AgeCheckWithOneHundredDoubleForVerifier(_verifier).verifyTx(proof, inputData);
    }

}
