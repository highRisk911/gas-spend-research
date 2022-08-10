 const EmptyCircuit = artifacts.require("EmptyCircuitVerifier");
 const WrappedVerifier = artifacts.require("EmptyCircuitWrappedVerifier");

module.exports = function (deployer) {
  deployer.deploy(EmptyCircuit);
  deployer.deploy(WrappedVerifier);

};
