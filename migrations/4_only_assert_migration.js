 const Verifier = artifacts.require("OnlyAssertVerifier");
 const WrappedVerifier = artifacts.require("OnlyAssertWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(WrappedVerifier);

};
