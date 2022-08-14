#### Motivation
For use zk-snark in commercial - we need to know the amount of gas that the user will pay for verification.

#### Experiment target:
Regularity between gas costs, complexity of calculations and length of input data.

##### Environment
Rinkeby, Truffle, zokrates
## №1

To begin with, let’s try to see how much gas the most primitive circuit will spend up, let’s name it EmptyCircuit, 0 constraints:
				`def main() { 
					return; 
				 }`

#### Verifier: https://rinkeby.etherscan.io/address/0x3b6FB72782539FA1a4B79c17f57FF4A0aDe3c604#code

#####  Wrapped: https://rinkeby.etherscan.io/address/0xf23CA78DceebD0b4421ca06cB953f0d9650F3956#code
#####  Transaction: https://rinkeby.etherscan.io/tx/0x251b5451ab53a1242254b40a9470b4f47e172924913c71581897ff7dd3362fb2
Gas Limit & Usage by Txn: 351,153 | 229,860 (65.46%)
Let’s add a parameter and calculate him, let name it aSquareCircuit

## №2

Constraints: 1

              def main(private field a) -> field {
                     return a*a;
              }
##### Verifier: https://rinkeby.etherscan.io/address/0xcEbAa83ad9D25132c335b2116dc519075408eDeE#code
##### Wrapped: https://rinkeby.etherscan.io/address/0x38B669dbb6F7D7e05e46b235bb56C6CC599d8325#writeContract
##### Transaction: https://rinkeby.etherscan.io/tx/0xa316f6516df501802809cf3eb5823d8a02998ad2d4b520a94ffb12f080e24410#eventlog
######   Gas Limit & Usage by Txn: 364,833 | 239,334 (65.6%)
  Pre-grown approx up to 10 000
## №3

Try to do only assert, let’s name it onlyAssert:

Constraints: 508

	def main(private field age) {
    	 assert(age > 18);
   	  return;
    }
##### Verifier: https://rinkeby.etherscan.io/address/0xFBadF80d4b79860B890E34C660Ed23Fa40C7722C#code

##### Wrapped: https://rinkeby.etherscan.io/address/0x700cf3D7CbA6D7b2a7c76b7F223a92d5811EECCc#writeContract

##### Transaction: https://rinkeby.etherscan.io/tx/0x15e30dd56680327455e0ff700e689a54e8f67ee0feec08e78ae369b7f5e2b8a5

###### Gas Limit & Usage by Txn: 351,171 | 229,872 (65.46%)
Intermediate: compared to empty, there is no difference exceeding 100 gas.
№4

Let's try to combine and write the recommended implementation of the age check from the developers of the ZoKrates, let’s name it BasicAgeCheckImplementation

Constraints: 1527

                           def main(private field age, field challenge_id) -> field { 
                                  assert(age > 18 && challenge_id > 0); 
                                  field proofedAge =  (age >= 18) ? 1:0; 
                            	return proofedAge * challenge_id; 
                          }
##### Verifier: https://rinkeby.etherscan.io/address/0x16caf67334c634826227e6288748c5056452ac36

##### Wrapped: https://rinkeby.etherscan.io/address/0x63A42CC5f50DEaC0b6458d87d269BD61BAE05bc0#code
##### Transaction: https://rinkeby.etherscan.io/tx/0xcdd3f50ce70ed35ec3645be6f39868ac7661d63187d9540bdc8a3d2245bf6c97
###### Gas Limit & Usage by Txn: 377,451 | 247,958 (65.69%)
Expectedly: increased by 20,000

## №5

Let’s add an additional field and look at the change in gas spending,
constraints: 1527
Name it basicAgeCheckImplementationPlusField

	 def main(private field age, field challenge_id, field addField) -> field {
	  		        assert(age > 18 && challenge_id > 0); 
 	   		      field proofedAge =  (age >= 18) ? 1:0; 
	          return proofedAge * challenge_id; 
 	    }
	    
##### Verifier: https://rinkeby.etherscan.io/address/0x668B32f7f2339521b93722eBb45A832B39bbFAC3#code
##### Wrapped: https://rinkeby.etherscan.io/address/0x08478352BBE22899bB1828C38dC3e91b0E3dafF2#code
##### Transaction: https://rinkeby.etherscan.io/tx/0xd83fa3c892989d6ffcd3b8081a5550f0ce6a57a6febc51b031e2cd2a83cec03d
###### Gas Limit & Usage by Txn: 389,944 | 256,499 (65.78%)
A couple of lines of code increased gas spending by about 9000

## №6

Let’s add the multiplication of the result by the third parameter to the code and see if the gas spending changes
1528

	  def main(private field age, field challenge_id, field addField) -> field {
 	             assert(age > 18 && challenge_id > 0); 
  	             field proofedAge =  (age >= 18) ? 1:0; 
  	         return proofedAge * challenge_id * addField; 
 	        }
		
##### Verifier: https://rinkeby.etherscan.io/address/0x8E3c8Afe03727c8f900a8FA2C7E35cE7208b4E3B#readContract
##### Wrapped: https://rinkeby.etherscan.io/address/0xA9F26a8aa6ce155Df13546c791c0b2b7c43a1514#writeContract
##### Transaction: https://rinkeby.etherscan.io/tx/0x56096391a2096acf0900c6506416ea29c67b9e0c96a6d704f6b30e8a40a072c3
###### Gas Limit & Usage by Txn: 389,926 | 256,491 (65.78%)




## №7

Let’s try to add an array of 100 elements to the input data and see how it will be reflected in gas spending.
Constraints: 1527

	def main(private field age, field challenge_id, field[100] addField) -> field {
			  assert(age > 18 && challenge_id > 0);
			  field proofedAge =  (age >= 18) ? 1:0;
			  
		  return proofedAge * challenge_id;
 		 }
##### Verifier: https://rinkeby.etherscan.io/address/0x539117330EA7E2B2C4782a50f5819a48ABfbc820#code
##### Wrapped: https://rinkeby.etherscan.io/address/0x22FAcd08fc08C42Fc61B2bDE6030e6EA80ecB1d9#code
##### Transaction: https://rinkeby.etherscan.io/tx/0x9fa852f2b3d4665cf3c8fe18319846a6559758a9a4d6c06f9391adc005f09783

###### Gas Limit & Usage by Txn: 1,671,601 | 1,114,401 (66.67%)
Note: 99 input elements - we got 4.494 times more gas spended than one of the input options.

## №7

Let’s try to add some logic for that 100 elems.
Constraints: 1627

	  def main(private field age, field challenge_id, field[100] addField) -> field {
 	       assert(age > 18 && challenge_id > 0); 
  	      field mut proofedAge =  (age >= 18) ? 1:0; 
  	         for u32 i in addField {
    	        proofedAge = proofedAge + i;
    	        return proofedAge * challenge_id; 
   	       }
 	    }
##### Verifier: https://rinkeby.etherscan.io/address/0x71aFeB7785c902ccAA30410458ca7E4C46fd5077#code
##### Wrapped: https://rinkeby.etherscan.io/address/0x572fB9851504955772194AB8D26262D73B2464FC#code
##### Transaction: https://rinkeby.etherscan.io/tx/0xbd2564141ef36dd1b9fdd42ef60e1f9de37eb05d7de28aedbf5c99fc279a805a
###### Gas Limit & Usage by Txn: 1,671,583 | 1,114,389 (66.67%)
The additional for loop made compilation and calculation of witness more difficult, but did not affect on gas spending

## №8

Verification eddsa-sign

Constraints: 90600

	  from "ecc/babyjubjubParams" import BabyJubJubParams;
	  import "signatures/verifyEddsa.zok" as verifyEddsa;
	  import "ecc/babyjubjubParams.zok" as context;
	  //this code example from https://github.com/Zokrates/pycrypto
	  def main(private field[2] R, private field S, field[2] A, u32[8] M0, u32[8] M1) -> 	bool {
	              BabyJubJubParams context = context();
	              bool isVerified = verifyEddsa(R, S, A, M0, M1, context);
	        return isVerified;
	  }
input generated by the next code:

      import hashlib
        from zokrates_pycrypto.eddsa import PrivateKey, PublicKey from zokrates_pycrypto.field import FQ from zokrates_pycrypto.utils import write_signature_for_zokrates_cli
        if __name__ == "__main__":
        raw_msg = "This is my secret message" 
        msg = hashlib.sha512(raw_msg.encode("utf-8")).digest()
        # sk = PrivateKey.from_rand()
        # Seeded for debug purpose
        key = FQ(1997011358982923168928344992199991480689546837621580239342656433234255379025)
        sk = PrivateKey(key)
        sig = sk.sign(msg)
        pk = PublicKey.from_private(sk)
        is_verified = pk.verify(sig, msg)
        print(is_verified)
        path = 'zokrates_inputs.txt'     write_signature_for_zokrates_cli(pk, sig, msg, path)
##### Verifier: https://rinkeby.etherscan.io/address/0xb0aA78Abd4cFe45Da75ed6bED1915aFeB1E5Af25#code
##### Wrapped: https://rinkeby.etherscan.io/address/0x1a67ED1Db5925bD5E7fA19A4269FCf2eF15335Fe#writeContract
##### Transaction: https://rinkeby.etherscan.io/tx/0xf10ca10812459aa1d64d7aaae51af0f36541dbb699f0cce267c20d9a362eed88
###### Gas Limit & Usage by Txn: 594,114 | 395,998 (66.65%)
In this case, the gas spending is approx 400,000.


### IMPORTANT 
"Warning: Contract code size is 127133 bytes and exceeds 24576 bytes (a limit introduced in Spurious Dragon). This contract may not be deployable on mainnet. Consider enabling the optimizer (with a low "runs" value!), turning off revert strings, or using libraries.
"

So we have limited space for smart-contract, therefore we can't use so long input as we need, practice shows that we have error, if try using 1 000 input elements.  

### Conclusion:
1) Prove complexity o(n) – compilation time, computing witness, highly likely o(n);
2) Verifier complexity o(1) – verifying always for the const time;
3) Amount of the input data directly influence to gas spending;
4) Complexity of computing circuit influence only to compilation time and witness-computing;****
