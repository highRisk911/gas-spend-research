 const Verifier = artifacts.require("ASquareCircuitVerifier");
 const WrappedVerifier = artifacts.require("ASquareCircuitWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
