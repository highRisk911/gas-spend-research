 const Verifier = artifacts.require("SignaturePerformanceTestVerifier");
 const WrappedVerifier = artifacts.require("SignaturePerformanceTestWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
