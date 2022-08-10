pragma solidity ^0.8.0;



import "./AgeCheckWithOneThousandArrayVerifier.sol";


contract WrappedVerifier {
    //AgeCheckWithOneThousandArrayVerifier.sol


    event AgeCheckWithOneThousandArrayVerifierEvent(address _verifier, bool result, uint[1002] inputData);

    function wrappedTxVerify___AgeCheckWithOneThousandArrayVerifier(address _verifier, AgeCheckWithOneThousandArrayVerifier.Proof memory proof, uint[1002] memory inputData) public {
        bool result = AgeCheckWithOneThousandArrayVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneThousandArrayVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneThousandArrayVerifier(address _verifier, AgeCheckWithOneThousandArrayVerifier.Proof memory proof, uint[1002] memory inputData) public view returns(bool) {
        return AgeCheckWithOneThousandArrayVerifier(_verifier).verifyTx(proof, inputData);
    }
}