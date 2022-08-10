// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract AgeCheckWithOneHundredDoubleForVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x1f59cf48d8382a8c2ffda0d03e1f46779d44621d6d14bc36407a89dbb779b412), uint256(0x10d20f987e1bdff18f47a4a53923d481278440f5d91f70d8c1018f7d67651e48));
        vk.beta = Pairing.G2Point([uint256(0x25e51eb27bf872b695695e1d3d8e3754aedcd02a7f9b87cc9393d0c2b71adf12), uint256(0x0d0c2386b35ba45f56deb707308c8a4658ebec3bfb680b3444cc8b5c9451c185)], [uint256(0x2021344d4e40f08c0ebc1b6d0af2df3d486458d363f4b1b3498f1b76e125adb8), uint256(0x09c8f880821019595eabadce03f5abe83b6e5409d73fdd8af4dd3d8ab32d2a74)]);
        vk.gamma = Pairing.G2Point([uint256(0x00c3166a7cbf9d1a1fd65fc7ddfcec2a11a841b27353339b1c52bae2a16f917c), uint256(0x1b326b678853577ccd0f1145c55db5386c9c7673599567935adc086b51f66c32)], [uint256(0x2dc473f9e68e73170af25ce360d0448cbd68e4a1afb9ce3e52720e1ecc8bb103), uint256(0x1a8a12ae422354180b08abb41a0e535c00e176f7d0352ebc9b343b8b8f5f37c2)]);
        vk.delta = Pairing.G2Point([uint256(0x2c2bb1cde916a698b68e6cd8cee79d1760a91aad496180a1979304321fb7f04e), uint256(0x192622b136c3b54d24565cf14b35fc6f9f053c1dd76fd2005127c011192196d6)], [uint256(0x031d425cc60027154d0a54743857821084313f4078164215025c01d6d28fe768), uint256(0x1955d1b0b5b3f24447a797b22360bd4cc18cc90ac580a7de4d40741fa8fe1023)]);
        vk.gamma_abc = new Pairing.G1Point[](103);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x101cf711ef4e6bc14a63c79c48342870d19ec84baab5c38f062c224b1f3f463d), uint256(0x1eb58ddadfad0741c5716eeb0952a15ca1b01453e3c45199040e7d7d5d119d9d));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x025d32b5f861e2b2742e1f8de56bbf347b11844d48125144e77ebdb6657fa9f9), uint256(0x032a7c7c8c2dface3d33ba85417695c3d8d19bc9ea66daeeccff198c3e23efaa));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x097b1de2f65b4422589f29efc250e72c20d09c60786c032b03e44587dcf08f0e), uint256(0x18a43ea770f8c05f59fdad7aaf4e60ed7decf17246ba2a4dcdf2f39860b3e60f));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1072532309d0c7b4bbef9b8ebe3f99f003c085f42efd49e436f61a34d02a8f34), uint256(0x2cd81d3cb6acda31684bf51ae19efc6e16cc07afd48c252398eaa51837a97312));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x202d23691c130ce8e1bbd0849dc471774e8e6e545227100bb0f806705ba74c97), uint256(0x27c9ee96c191f9a5c969f4453e8891dbd8c6f7b690bc798acb7c513e6c5dc0d7));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x165f82e9c027ae12745069476495a371492ea16ea75fd251ed889ae78efde888), uint256(0x165efea5f10caf68f60dfa2e18bc164dbdcd91dd1054786774d0ee979dfe3427));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1130bc2996184c4d68d9af1cefb87171be9d4ce77a06cbe5de2f1d82fd64eb52), uint256(0x292deb2ecf4b3aaab65719761df7ea0f5943eb0aaf0223d9067787e52776064a));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x13e0cc8eac97c7bc06e21bbdbd0f9fda0f774d39e575051c77af3897b3e58ef4), uint256(0x2462539cd502664d64bde81c55a82f76e5fc6add235474c0a0494d974463eac3));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x284f89b9e610a66740c8b126e87547389699cb20c4216dadf88b10688c73144f), uint256(0x2372bb5771751f9a22c082af3e9d869452cc727d8fa2d708b7fa231b27767997));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x264192228366bd08145a439bfee259c8007b0b2e5f158174bb22b18f3d8f9737), uint256(0x01afb430dacc735151e90408bb54a02a9e28e0a4e10218bcb243110c46a17319));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2ad7a92da1f65264348986872b77666bdcc843cfa608222556d6c8d7ca40ea34), uint256(0x2357b1c77c2ef8eb0638a27c8751565c1206714e52342af1c8cf23c2b3da3575));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x11425f72887b9d6ccdf5c69c48542b662388b7beba4ae7639bea64da0b700a85), uint256(0x066aac372b167a49d645d7dc12bd26c58ae58caa8508b78e293b75b951bcfd22));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x29d98c78e3fe1977c5c1ee7239732a6774d899ae5d2d849de2c54067003a21fb), uint256(0x2b2ac5a77d3d107a9441bdb53e259996df73e38d1a43a698a91f0076ed3bbbf2));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x0e2805daa40417238b96ea8997a516810bfc1b40d6d8f5816ff558927cc325fb), uint256(0x281dbd22a9119efb6f85a2c85e2fc4593f8f2bbfafed760d1a2ac191086b9144));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x181626aac5e319ca355b953bf44a4385ec768a8b80a3ed1020efc5960a3aafa2), uint256(0x0db5d26c9eb5bf32b685c3257f246ebf284caac06bb1485cc5b5ac94a5342cfb));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x255d42240b51adb42e77cf30167ccf36e8f78428cce38812e00925ab039665f1), uint256(0x14a6e7a58ad25f8f289f51e250b6e00e1222630a11d7b1d868984fc3f54990e4));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0ef4665a7145d3748946327b01580b63d231f5960cb2c8f21fa9266115b934b1), uint256(0x2564f78309adbdc3291a63f5980e94439cf655373b7db0841a32c4c71c21ee6c));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x17f26060cc95df7f6a78433380d1bbb09d842d31c3da3a044996df06f8582921), uint256(0x227ee6fb925d961a382ac67f9fa264c0c528c081823332b4f5a61cdd594c9803));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x277d2b103e7cf29b44c39c3b73bf272bc2e9bb32ca7691153b983e214ffa7449), uint256(0x2d2322a5f35a4107b6a5849545fa5c3abe57ec08c4da383e1054e0cfb8305100));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0aa4456f33dfa2fa1086527b86c18ec940d5f48510a853544702b7fb8000bc08), uint256(0x19498e203578e1cb6261bf6294e127f6dfa8d3440435bded01d2c058f728a1a8));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x2fb1634ef15feeab9eb4faa3162c351dae4b3589fc98822efbb5f0a91c783385), uint256(0x25c0bd90146629b4ae7ff0b434430e15cacf4ee22ad301afa015c188dfe41cbf));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1bdf82128009903c634fc379d46d874d703d8485f965dfba742d4313650784dc), uint256(0x2452637574b5f34db1a7a390f6285576dad9a964b014e9bd3ee76e4e4fc21f7e));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0e2ed5f117eb566525aba18adbc08edf1650de48558811b87014fe75f9ba2dc6), uint256(0x1a00140d8f5f68f945e4c6a406d4a627b36b415188e3f857173e86627ba9831b));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x091ff07a651b40625039d0454c7c6d1d9278c49c72d63e58deddc40aaae849fb), uint256(0x27af9f51b5eef9925bcbbba5e21ff27bbc2b552af5f84801829fbf017402a806));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0d30dd61f0bb422a07f77e9cca55395359fde007a5617989221f3f901ac17081), uint256(0x0509e9452c0d123e32403594f8543bdbe6bba23ac75635cde69958a9f90a3a66));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x19592568bdf83b6cf268b1fa8ea0992c452a5758a620389b7c2f5f030ae65ea3), uint256(0x20626a6c23d76b8e4bdac0e6e4a4e7792cb05a8a4c906e4913e7973053291022));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x251dfe2e1cfd5f56b50a5faa3d728ff8a0d1644b95a0a98530893a80eddc4e90), uint256(0x0ab10c4f43d809d0b45f51aaf16dda80f90a492cdb31abc3e6a18f974d9ea68a));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2d9fcb159d3f644691474fe3a4705f750f42b4c77824dee6c5fadb991b3c3226), uint256(0x1e91ffda5cc7b7fb9fcc778a9e70e41feedc0c701449535c756ed13e95e48e1c));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x21132d8b97a91fac7d3bcd9a2402e6ee460d06b123a40b1a77620c5aee5eb92b), uint256(0x190b2121decc89eb58e2a39490b20be6149aeefbbc486910d3a206fe2d2bd2ab));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x277b074d6d1ea12d67a099fe65fa24582c25039685fda4fa64e5f033cb98abeb), uint256(0x2777cbc2dd6c4d13b717878166b46fb55a40bdde341336331191915af93723e9));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1b6a67307b36b9f52be90d4ec13164745fe131947812af618a51740e73e75156), uint256(0x223b9f91ea732acce0c89ee2c3ada4333bd76c1cb042bacda3c3e4649c444768));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2764723559501fe434756d7627f6620d507e20aed50ae1c8a68cf7e5f0e56ec4), uint256(0x19aca1394d6fbf754c247065fab4bed6f3d5ec30fe6e3151516f3ca3f76422f6));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x06c58bf23ad03bf501bd6f06cac941f28ffc4be3f1088170dc5d1770592d698a), uint256(0x2e82c99f6704275161fa0f03d065c863b510d41b378d0bedebaa07427c824742));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x112aadc20a49b02ab237f1b6bba5f09c10027305c25d0690dcd2f47934ffa783), uint256(0x15331619bd21acbc5babbd2baf77b691b710a1ce4f3069955e7fe667119b5154));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x1a8e054fa7e55887f0748a250f41af9086007b0903441defb471167805ff1a69), uint256(0x28fe99696c2c7a5083e54eea65abd727b1e28f2d64976bb801f16768e3583649));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x12f3c6a045a4b254992020072efa623ec29d84c207958e4636a62ff0789d52ee), uint256(0x1608a0d5f81088e43f48027b32ddf7c8b53f2580b4e1a60a339485dc626ee2fb));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x24433cd6d427965b0e2773166ccbda8e596424fbca72034a23198bbb9d6530e0), uint256(0x0ce8a12e1fbc34b42dd816ce3e60e9f0c1384afcc5327ca51ce330d8b3427e8c));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0a62d30d70055a9902a0f7df27440e02daf42a028ba3e62cb5aaccc065a7ee47), uint256(0x20881b63da694dc68a737d19d1163e35f87d9fd077f30a2c6c09be4336107c34));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x01ac5f306cbd7f0e7ebf47750b446f43528f1105a5e9c1a86a6a6f0ee568f106), uint256(0x2dbdb81ab56dadd75eb66c61ef0b090c1a02830da433e33a5abd7ae780e2d87b));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x2741ede5910d5c13a001d00690b2350be6ce0b613ae8caa40c27b24082009b69), uint256(0x022cc87f2aab2029467e0c89b48b2e7ba9d30d4f2ad16acc5cebb16eb5c7df60));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x0a6cd8ea58685f7075efe04b633ccb534b77e08495a3caf5b1c76cbc313ed4dd), uint256(0x0cc99d1260ae732722a4ac737efbfc2324eeb0e418239c530cd73c0bb0cc890b));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x05e336ac395d22ec4f28470c4bab1445c6dd9838b8ff55c2d46bf1337cc64954), uint256(0x0d5bbd4425f0910bba6a7c23f75b86483678b1e7bb133613835f050bdabef295));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0dab3bf1a6ee3834685625c38cbfb06f488890dedc027bf731650e99204e8389), uint256(0x1a6bcdd0472a179e10764e84f07b05a6151087232174543fae8f8c2e72092caa));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x061f63f96e83bf53ac7255c21bce922d60d14b5a19509c7618e48b00304bd3c0), uint256(0x1346f5a95dd87a6b6464c381bdd47a38ea06dc3170ad85f9a2b2b4d2646f30d2));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x2399be72ff0708912525accb4670de9c54e219a50b6b4065f24ad63cb2232215), uint256(0x12acaa2a3c982aa1f50e46ebfa0ae3d1e2f34397b151f768925ac498bf5efc09));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x07ef4835913dc3082165bdeba4cd634dc5e7988fafa3ae6d685353d9457f97ac), uint256(0x2362a6966dab7688191cb655e7eddad6c6e98a139faeb1e1fea9aaafe0b94484));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x23d6c616431de6d0212220cbe7748d99a39aed44be38da3e4049c9fb99a3c0b7), uint256(0x0b7d0fc904def984482048c7af740ab38decbd0fef6c19c24a8bfada959386c8));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x09d3e9416aa5429f969d43e12e658850771bfee4dddfeb268b5768c3b94d0b38), uint256(0x21ba395ed4c9ba9ac508a07df114c07c4e1ed54cebe95c9a310bf4dd0603e5fc));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0558ab1e3f6e4d2f4774f07fc3c4a083ecf6a1fb6e39c146f1e2615c4c83c4d2), uint256(0x295467c79a76d49e1137d0097378bdb36570e22d658378618c8980f7f69809cf));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x27171f8fbd981405d9732ff0b1bcfc412a8ca31de9e6061188bb176d59e6bd10), uint256(0x27805b3d8721ff562e7c358f962552484c8ab1fa75d410c178449b3f82f3c2f1));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x069a346a95bcabc510963c5a286fa44910a217ba79aae8ad8dab984b9b19acea), uint256(0x23bc157bfeaedbe4bad40520eaa0c8d3bc50dc4037a0f5333d3d85c8cdefca16));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x0956501be661a6cf76a65542eeccf60f3161d24aff47da4d270c091bea33d4f8), uint256(0x16dc85d88251d7a020972d3ff371fa0e2e71c4d91dbdc83b96a5b15f362b79fb));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x0f54ae1673fa869124faa08a0edee1256ffc73c237d40283c2b2abcdc315a407), uint256(0x1a1ba0ebf6b6ca72c7e4e1bb75bc261c1b90f51a32e8ab05b620a9904033103f));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x241488738b819b210e80fd84d86bc54821929f10d130a1def8a87ada6e3903e4), uint256(0x0a63b974b8a1610a4c20cb16abf059a24cf78ac8b4b63d609c6ff4abda43600a));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x1f8bbc9bb2b5a4c0989b940b0bf54162665051f906aa2885c8766db7861b1352), uint256(0x14f479ab084b3788491d5d44c37e1acb0b930882b0f5e778c0814554c04cc6d9));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x21a5d19ef2e61347d013465bcf88b776d1bac81728a8cb09bc7125cedb9f8943), uint256(0x10a7a95e37f22fee60a8f09fe11300e4542d3407836efe1931b250836e42155c));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x11bfc009d88ea0d5c1f21109414b8b74c9f24e5f432d31293908ca61408088a6), uint256(0x00e8d16ac1552a689b47f4f51dd4242f6952f003ecd8397a530d2c07e72f8c71));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x2a195d5f96fc08e9d587d85906dad65802741f2a62525e72008e4012baada1f4), uint256(0x22f0ffb585e0f3e5bddba920d8192cf611ff2e4b9adb73e18bbc28f94e57df55));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x07a490629f36bac547b3e3282753823b4a97c4381564c56f91ba7b5763eef0fd), uint256(0x2e9731b8994fe6085a3cd7da8c88ac19dce6c4aebfda6d506000dfd957d3bf73));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x0493dcaf99fb592cdd1605b063184674a59fb59fcd6303b9c41be46cd29be327), uint256(0x0d87261770b65ce826f530bd65a5d4c6511c5952793fde5db28f1725c91ace4d));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x138c5ef676c9a1e5eae1b37c02686b9f71e27d454c8df40e88edf746035f82b8), uint256(0x0867a4db215af8d5f929c8804461d1eaf5253c532ee6bfc409572aedbcd4f808));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x20437bb3ae3514b8fbc8174e7de8d4cb5d1b4a315ef9753b800fe9900bc5a490), uint256(0x017944b8fffc3086bb08d3e9a63782d482ccf2e088620040e760ec8ac6c40170));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x09bff93c2d40932c09efcb11b3b8af0966951f91ef521bf30df38a9886d68851), uint256(0x11e16cfe26167f756eb7012a80ee08ec9e74cc2bd1e2a1b6750e601079794efa));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x23a30753985bcfc661f80af66decbb9deca8c0a8fd4a500795af8f07d9135d69), uint256(0x2029d8578b96bb7cc9f2f734dcf548d86226de9c7174624e27f6d08ef633c13c));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x0f72a59ce653e78be0b705086691b97e717a75f7b2ea09a76979a617a86f6547), uint256(0x04ef3f5b990182426168126bf636834e5f8148e1ce0228b934bbda067cf24730));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x21083b02df469ed571f799fceaabf2e17d8ab6ea25197067d2636018a7ae2496), uint256(0x103ac95a6efc4c0e537a70b28fad3f34e64c4f328a0c420651b18e900f697a53));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x2cc0fd0a75fe111e98ccb81803e66529deaf3a3174fe71d53ebb4fb67d96feee), uint256(0x1d6345d10df422d06ba21eeb1f95738015119b795c060f80d56c97076a569334));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x2fa50713fd45ff63ff7df3b45d32d3fb351f9f4866299167e9538b3da5b55e9e), uint256(0x0bbb3a0456f25ac23dfc974130e7320bbf23333ecae02f6f51550520c08229dd));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x05a3cd9c2d896535f0bda0810df0f54fb9a77496a2b0254a02264b44c7f85b6d), uint256(0x129812096c5237278742265ed322ac7f423b15d14481df63a90e1a76e6c16981));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x2e7a39372448843aa193d26de8b3d07595efbc56c1a4f9f1bf62030d214dd3dd), uint256(0x16c421c555d948d0e7d731494affeb43d1c83be29ed2bf2574e19c59f6996f07));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x2a08947102fe5fd0986ad9de004e2790847e4f7f1dfdc2684a2ebfb91b58c4a6), uint256(0x2c0b60b3c13f5d56a6981daefc67d938a30d0c2be4a97091f7b59736729d255c));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x04f9f17fdc2987d9b05f749ae1eec832f50babaec3c2c68b57590326dfbd4313), uint256(0x2890e33205b4c976ca9984483e988c5a1f2ba44a545f526e1cd6c7435cc1a0ff));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x2b82c74f98c77e105c2eed6fab5b59b7d33816aad65ffccd494b8a4fcfbd312d), uint256(0x23be251d0acc68182c187bf19f5be9f788b2a14a9c98065336d7409b1c3170cc));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x2fd34362f72b433ff8f5f2c5a17d9a63ccc4c4b8dcb2707708a8cb1658985105), uint256(0x2a515b83da5d0b6b4bf4756b3c4b068341a15f3d2ed9fdd78ef6a40a06614b3e));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x06eacaf978691c795e6cb638ae4e1b4502727c298978c2206e15968fc2953716), uint256(0x27634f21a583047003488c173f125d938b6090c863e4f30345542406d0195356));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x065a27fb8e2125c4baff9b9fabc2f252372637b7559a202eb3e5b7d863a684f1), uint256(0x2ddf63c4eb76528141f12de9f1c845bf3ca1fc980261430f122afc3a34749482));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x16cdac193497529a0fcdaedbeb5c22b20ff2532769db4c224443b2e94e1dfbbf), uint256(0x285deacc2b8d388c7df7356a2475e35c2f7daea616b3fc92acd31fd2d7dfa51d));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x23d84a17bf126f66122b84a8ee84c0cfdf23a6a52f24945a68f69bd3a42ed7a0), uint256(0x23cf9ac8bcbe08fdc973e8f8caca11086d5ddd080cc3fe3f0df47fc03824e7fa));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x0548a198586f4044c8c2c84cc4f7839b0230f86013d0d8cf276c57201620e95c), uint256(0x25a56cc1590ddd7c731b1ecff9b7937c1f42e1cd04aebfdb405c68e9f6f5a122));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x256534209aa80ce5e4e9e2dbe1af80268e6dc4a857bd83a6e885d0a7da819ba1), uint256(0x10697d49244377e4e3fa2b173889f3b67a71414dd358a3aadc1224d402e7592a));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x23806351ffa84f5f0c501330d41c9089d27d35b0e70a121543f8148cc93f6598), uint256(0x0d7db8127018fd4bcbece0d3ca842fb24609bc1e18ed322e02845437723bf7fa));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x1fd4e40717fbdb462289054611798e7af4575f327edce09fa275f8335a3025a8), uint256(0x0fb22bffd517966f2fbb7b07f9e506eb148affd3c087a663520af4d1b14de6e3));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x22a75b198944d8840c4b30ad40616bbc583b577fc4c7fd1922d2a1f5e82437b3), uint256(0x10d30c54c81fe5905c5af4b6ae8aac662010a8c9cffd3c901d869c6e73b17c8f));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x22d2d31cfe32b66449c70f2149b7b45234bd8b4c3106f51c8a7a297a87025816), uint256(0x2cd9756cc0edbfdad901086e576e82885c77a8b0943da44c70bfa13997031afc));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x2c1d1727c008d764c2939525545368c61ab1e9a838764c2d0165c91d9bae0ff0), uint256(0x12f1a11e54369da45640c0ef74c79c40c3ceb1812bf1587e23371329ee2ba557));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x0fea76278ff27bbe142328e3e63e7b6d4a5f89917b743d22f59ca9541e4d2a45), uint256(0x15ffe33c1b9fd2e80d8110aba633145d67d00281cea77ec926de92c4f9fcb076));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x24276b98a8f12424ac4d03c35d16dbde2a00003b5cf896f4518d197dae328802), uint256(0x2ff8b056df2b452ba64db1e722d20461e00793f93a90cba77be5688f7a810bbc));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x2d4dc9cf9f703b2a8de31ae6f49229cc0b0e6b366fb8317380fa32d99f4de23e), uint256(0x219d99a379869cb32379ea8453b9010ce359c27680784ee405987d3665c0697b));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x21906d987d346c8da2c1f6e9b0c741e1aea42429e58db524df2a03740097fc46), uint256(0x29711c15af361930d90b7cb02325589257a7c330b63b6938cdebea5e725b4c5a));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x2f21b2b3b897979b8a3c0805905c78e6d675de6b592ec0ae8c48f259cbca0bb9), uint256(0x062b001da94696b50a0dedecb60267719ac238ff24abfda033a186846fc52f6b));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x2b405620120e578f5d2ccbf7c580ea393f7079b91b73cd3f091ea108c22049ea), uint256(0x01940ab943115900c956a0ec3094e26e445eb819199b4c1d35c66e60c561466d));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x0646f18268791d974d7a83d3062da84748c37292d94907ef1a99841434d05403), uint256(0x0d4bd048bf6c367159c95783bb0a89aa5dedaa1c45bdc29047bdcc4ef7282498));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x11c5578a1afd160c6d47122f715cca4253b43b023776e6e601631058b450d6de), uint256(0x0bfa0f47a224d277a9d987e619fb1c273ce979e41e944669211c7c89ab6d2fdb));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x2029254a5be3bf3724743da1b84332b43c1cddb314bb89f23e63660ee72ed4a6), uint256(0x26b1bdbb36ced1195b6ac616b577b3bdff8dc1ad7d711cc066a0590f3fe75a7b));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x2a3f0f4c4992877b6b67f8db4b67f5cce6efb890e155c189cd22e1d684a8282e), uint256(0x1e9dc52ba5823d5c8430921aa17b454cd185115637f7f1392c5e4009742f0969));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x14d13b031a310670e7f53f091e6fcd55b332d4622207bf1385d368506bbae108), uint256(0x29f1abd7d43a6d38fbe9cc5e45052fe21e1df099974e08d8bc97b931a4edc3db));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x2c5e029baf57adbc6d11a32a1e9871c9981dc6d6e9df6c9dd583e7692f6122ce), uint256(0x12fc2001a8ca19bda58a73204d33fd099c3171bb58a3b3a3d795bd3edd8c5192));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x273e65392027ce45d4a54b44275b72bf353d411b5adbea879c097efdc26d2be8), uint256(0x0db2c6cda72566f1c363233ab6d168bd8f5228816faa45a9f711b7bdb8101a76));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x1d835f64b2ec34ebe550fb99522ccf807311545961e5c66b1984c4b7634b668c), uint256(0x2352e8651cba550e2e2852df1613ca6d1a5c7bf225ccfe21e7aabdebaf3ca8b4));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x01d2f430fc58e60a4d050992d6cf1e4b38e278eaf4449c4fd7608cd94fb4a9a8), uint256(0x01dbc3f44b51b5681ac31ea6df46a9a1aeb52d924fbb84734013f5405d52eb48));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x2a17071b8836eceebdf4d1c375f9bb70c425fe7e77b91c865a6c0cf57eefdf41), uint256(0x100f683a43d84f047fe4792292ea9944cfa5efe8bcb2c1df5bcaad21e11ce72b));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x2a70690eeac09e3212a53278d85f43f0cac029081b758ebe85c10e0ade7a6b75), uint256(0x01d48fbed5b0b419d1c143460ba6e579b451026063233809c31705c08ca18621));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x14b2e7c32c328820abdca1c832325d26e1ae7fa3492938f682bd89fd3029ad65), uint256(0x2d36ad3d6a3fb6b6ef33787983d594cce8cc68dd695d27a37ad0a280063171c1));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[102] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](102);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
