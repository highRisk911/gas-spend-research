 const Verifier = artifacts.require("BasicAgeCheckPlusFieldMultipleVerifier");
 const WrappedVerifier = artifacts.require("BasicAgeCheckPlusFieldMultipleWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
