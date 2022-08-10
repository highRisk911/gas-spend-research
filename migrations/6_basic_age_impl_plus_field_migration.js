 const Verifier = artifacts.require("BasicAgeCheckImplementationPlusFieldVerifier");
 const WrappedVerifier = artifacts.require("BasicAgeCheckImplementationPlusFieldWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
