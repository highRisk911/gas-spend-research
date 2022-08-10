pragma solidity ^0.8.0;



import "./AgeCheckWithOneThousandForVerifier.sol";

contract WrappedVerifier {
    //AgeCheckWithOneThousandForVerifier.sol

    event AgeCheckWithOneThousandForVerifierEvent(address _verifier, bool result, uint[1002] inputData);

    function wrappedTxVerify___AgeCheckWithOneThousandForVerifier(address _verifier, AgeCheckWithOneThousandForVerifier.Proof memory proof, uint[1002] memory inputData) public {
        bool result = AgeCheckWithOneThousandForVerifier(_verifier).verifyTx(proof, inputData);
        emit AgeCheckWithOneThousandForVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyView___AgeCheckWithOneThousandForVerifier(address _verifier, AgeCheckWithOneThousandForVerifier.Proof memory proof, uint[1002] memory inputData) public view returns(bool) {
        return AgeCheckWithOneThousandForVerifier(_verifier).verifyTx(proof, inputData);
    }
}