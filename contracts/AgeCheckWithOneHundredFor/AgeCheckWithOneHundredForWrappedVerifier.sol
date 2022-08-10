pragma solidity ^0.8.0;



import "./AgeCheckWithOneHundredForVerifier.sol";

contract AgeCheckWithOneHundredForWrappedVerifier {


    //AgeCheckWithOneHundredForVerifier.sol

    event AgeCheckWithOneHundredForVerifierEvent(address _verifier, bool result, uint[102] inputData);

    function wrappedTxVerify___AgeCheckWithOneHundredForVerifier(address _verifier, AgeCheckWithOneHundredForVerifier.Proof memory proof, uint[102] memory inputData) public {
        bool result = AgeCheckWithOneHundredForVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneHundredForVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneHundredForVerifier(address _verifier, AgeCheckWithOneHundredForVerifier.Proof memory proof, uint[102] memory inputData) public view returns(bool) {
        return AgeCheckWithOneHundredForVerifier(_verifier).verifyTx(proof, inputData);
    }


}
