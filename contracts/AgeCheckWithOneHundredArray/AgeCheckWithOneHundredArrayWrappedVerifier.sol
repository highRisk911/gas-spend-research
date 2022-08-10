pragma solidity ^0.8.0;



import "./AgeCheckWithOneHundredArrayVerifier.sol";

contract AgeCheckWithOneHundredArrayWrappedVerifier {





    //AgeCheckWithOneHundredArrayVerifier.sol
    event AgeCheckWithOneHundredArrayVerifierEvent(address _verifier, bool result, uint[102] inputData);

    function wrappedTxVerify___AgeCheckWithOneHundredArrayVerifier(address _verifier, AgeCheckWithOneHundredArrayVerifier.Proof memory proof, uint[102] memory inputData) public {
        bool result = AgeCheckWithOneHundredArrayVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneHundredArrayVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneHundredArrayVerifier(address _verifier, AgeCheckWithOneHundredArrayVerifier.Proof memory proof, uint[102] memory inputData) public view returns(bool) {
        return AgeCheckWithOneHundredArrayVerifier(_verifier).verifyTx(proof, inputData);
    }
}
