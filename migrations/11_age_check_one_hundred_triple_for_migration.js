 const Verifier = artifacts.require("AgeCheckWithThreeNestedForVerifier");
 const WrappedVerifier = artifacts.require("AgeCheckWithThreeNestedForWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
