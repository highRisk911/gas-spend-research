pragma solidity ^0.8.0;



import "./OnlyAssertVerifier.sol";


contract OnlyAssertWrappedVerifier {
    //OnlyAssertVerifier
    event OnlyAssertVerifierEvent(address _verifier, bool result);

    function wrappedTxVerifyOnlyAssertVerifier(address _verifier, OnlyAssertVerifier.Proof memory proof) public {
        bool result = OnlyAssertVerifier(_verifier).verifyTx(proof);
        emit OnlyAssertVerifierEvent(_verifier, result);

    }

    function wrappedTxVerifyViewOnlyAssertVerifier(address _verifier, OnlyAssertVerifier.Proof memory proof) public view returns(bool) {
        return OnlyAssertVerifier(_verifier).verifyTx(proof);
    }
}