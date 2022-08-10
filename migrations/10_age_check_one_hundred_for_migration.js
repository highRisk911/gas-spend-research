 const Verifier = artifacts.require("AgeCheckWithOneHundredForVerifier");
 const WrappedVerifier = artifacts.require("AgeCheckWithOneHundredForWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
