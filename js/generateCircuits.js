const { initialize } = require('zokrates-js')
const fs = require("fs");
const path = require("path");
const os = require("os");

const snarkjs = require("snarkjs");

const emptyCircuitCode = "def main(){return;}";

const aSquareCircuitCode = "def main(private field a) -> field{return a*a;}";

const onlyAssert = " def main(private field age){assert(age > 18);return;}"

const basicAgeCheckImplementation = " def main(private field age, field challenge_id) -> field {" +
    "      assert(age > 18 && challenge_id > 0);" +
    "      field proofedAge =  (age >= 18) ? 1:0;" +
    "     return proofedAge * challenge_id;" +
    " }";
const basicAgeCheckImplementationPlusField = "def main(private field age, field challenge_id, field addField) -> field {\n" +
    "      assert(age > 18 && challenge_id > 0);\n" +
    "      field proofedAge =  (age  >= 18) ? 1:0;\n" +
    "     return proofedAge * challenge_id;\n" +
    " }";

const basicAgeCheckImplementationPlusFieldMultiple = "def main(private field age, field challenge_id, field addField) -> field {\n" +
    "      assert(age > 18 && challenge_id > 0);\n" +
    "      field proofedAge =  (age >= 18) ? 1:0;\n" +
    "     return proofedAge * challenge_id * addField;\n" +
    " }";

const AgeCheckWithOneHundredArray = " def main(private field age, field challenge_id, field[100] addField) -> field {\n" +
    "      assert(age > 18 && challenge_id > 0);\n" +
    "      field proofedAge =  (age >= 18) ? 1:0;\n" +
    "     return proofedAge * challenge_id;\n" +
    " }";

const AgeCheckWithOneHundredFor = " def main(private field age, field challenge_id, field[100] addField) -> field {\n" +
    "      assert(age > 18 && challenge_id > 0);\n" +
    "      field mut proofedAge =  (age >= 18) ? 1:0;\n" +
    "for u32 i in addField: proofedAge = proofedAge + i; "+
    "     return proofedAge * challenge_id;\n" +
    " }";






// initialize().then(zokratesProvider => {
//     zokratesProvider.compile(emptyCircuitCode,{
//         //location: './zokrates/emptyCircuit'
//     })
// })

initialize().then((zokratesProvider) => {

    fs.promises.mkdtemp(path.join(os.tmpdir(), path.sep)).then((folder) => {
        tmpFolder = folder;
    });

    const source = "def main(private field a) -> field { return a * a; }";

    // compilation
    const artifacts = zokratesProvider.compile(source, {location: 'asd/circuit.zok', snarkjs:true});

    // computation
    const { witness, output } = zokratesProvider.computeWitness(artifacts, ["2"]);

    // run setup
    const keypair = zokratesProvider.setup(artifacts.program);

    // generate proof
    const proof = zokratesProvider.generateProof(artifacts.program, witness, keypair.pk);

    // export solidity verifier
    const verifier = zokratesProvider.exportSolidityVerifier(keypair.vk);

    // or verify off-chain
    const isVerified = zokratesProvider.verify(keypair.vk, proof);
});
