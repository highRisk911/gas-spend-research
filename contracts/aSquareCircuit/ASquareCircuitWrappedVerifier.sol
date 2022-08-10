pragma solidity ^0.8.0;



import "./ASquareCircuitVerifier.sol";


contract ASquareCircuitWrappedVerifier {
    //ASquareCircuitVerifier.sol

    event ASquareCircuitVerifierEvent(address _verifier, bool result, uint[1] inputData);

    function wrappedTxVerifyASquareCircuitVerifier(address _verifier, ASquareCircuitVerifier.Proof memory proof, uint[1] memory inputData) public {
        bool result = ASquareCircuitVerifier(_verifier).verifyTx(proof, inputData);
        emit ASquareCircuitVerifierEvent(_verifier, result, inputData);

    }

    function wrappedTxVerifyViewASquareCircuitVerifier(address _verifier, ASquareCircuitVerifier.Proof memory proof, uint[1] memory inputData) public view returns(bool) {
        return ASquareCircuitVerifier(_verifier).verifyTx(proof, inputData);
    }
}