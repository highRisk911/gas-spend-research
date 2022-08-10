 const Verifier = artifacts.require("AgeCheckWithOneHundredArrayVerifier");
 const WrappedVerifier = artifacts.require("AgeCheckWithOneHundredArrayWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
