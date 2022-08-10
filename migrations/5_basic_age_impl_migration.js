 const Verifier = artifacts.require("BasicAgeCheckImplementationVerifier");
 const WrappedVerifier = artifacts.require("BasicAgeCheckImplementationWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
