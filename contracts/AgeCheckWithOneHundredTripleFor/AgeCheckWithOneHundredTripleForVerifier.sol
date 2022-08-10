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

contract AgeCheckWithOneHundredTripleForVerifier {
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
        vk.alpha = Pairing.G1Point(uint256(0x0a2948573cd96a8f3fb38341b91d91cffb2b2ff03b532d4d73d512468b3e2a07), uint256(0x18ac595290b6fa74a423a0ebe263ee3fc14e7f4cac2e71f537f1fdc9087a04b1));
        vk.beta = Pairing.G2Point([uint256(0x0111416e4c5639d211329527bb16c5375e795363068c21b1aaff3dd7190ca638), uint256(0x2350a9b02f637350152980ded0d6d36e41d0a47762fe329385a458f9e499e5ce)], [uint256(0x22c9b9203f1b460d989833b76902a80c2a76f15e98e4fbb1e2f2736ddda28146), uint256(0x2cc99a10e4b137e1d155599a55975e9e532d6438fbf7e85e2f7df2c826d95d1d)]);
        vk.gamma = Pairing.G2Point([uint256(0x0a1239e84aeea3e09af6fa57e63577b209de2d8b98737c96e495eb02633aed6f), uint256(0x08ea9efc0b6f2eaf8e124962585fda5ae3fc8a82538b852913b5ce7c65c59fcb)], [uint256(0x17050903235813dd2cded714b2d32c9840e21b29af1a920d7e745a78384739f1), uint256(0x23ad9adb3900bdd61b03065483983eff4c858e48aba8fc3dd26a1dc6b53595e3)]);
        vk.delta = Pairing.G2Point([uint256(0x01e28321884a10468ef0563c8c812d1b953201e0421d811048c5acf8067b0c9b), uint256(0x2314f37f581fd9e1ed67fa8a6674730ca9363ccea9bdc547dec7dbab4363b1cb)], [uint256(0x22db234153e40fa205f30d8e9c8dbead23dbae81d1e33896f6af30465ba4d2f3), uint256(0x06847eafc1cb4154582f0ee30dcef269ddb4a4767b639817028d52570d0977f1)]);
        vk.gamma_abc = new Pairing.G1Point[](103);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x06e615cbe98e1fb4aaa1f15e8dcef969da154074ec0f03fcf64cc6dbc09183d3), uint256(0x109cfd1de2b747e07f894f70af742ad16cb872429a574acb205ee10469e62a01));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1cc362cbca3d40c726e26fcea3f4efe354c607d62b1c1a337f1e2fa4b0bf5a30), uint256(0x2c9b0ee3bd744885fd4c0cdafd238bd6b1080b01d2f549a7cb9264bd49edeb11));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x087264ac88abb1a19f5f24b977971a0186e0ceefa7c050c9d0e6b160f1346d16), uint256(0x25f4fbc76835aa631611271e3e3816996b302d190169bb392b4a207235cb9bba));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1edc3707d92ef913bcff219d11079d9d1557a2412945ee380fa52737c93cd001), uint256(0x2ff8a6073b19f88b5607826d85ec8a59733b26e8912b54f2428d55ce498ad444));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1697b4c2d3e378fd797c0cf725d3c349fa7c417986a48eac272ac067898c8e47), uint256(0x057ad3ea75170195632b69f77e80862f3dfb5ce56343c064328a20ce177aa888));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x15856284b02e9a28d6fc349d6fa72740a6dbbf9bbaf7e8d6112b5b12163384de), uint256(0x242a1bbd958c9c374e218f9c482ec51c64ed5fe99144f3ad5b16dab733a458d3));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0f176a1dabcac3eae990131fbf6da753f05375d7f2a2cf175d6c22b8401337c3), uint256(0x1b872369c4c18d955d9820001c54e011ec6a94e02f8b92a806d7574227e52f94));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x01edea5e6e85a0d6cb0725ec051f2d0273916f2ff2b723c4da34bd0aacb8b868), uint256(0x04e381c9f4a9cfcd0d5f984aae59076857f767da09414af642030f50eb9fd2ea));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0db091d2eef3d31fd41273b4a84c98e95beda5a26ce52fb3bb491c932dd1d1d1), uint256(0x1f59eea21d155ee7aa6b8b256c80b689d030b119078284596da4bd93f694a0b5));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1770cfb880938e7ce0131c03bc4f40aaffcb4652153308012f63077f8cdc9e05), uint256(0x11764f7c8049af20c7ed031fb5ae82325148e1b0729316b07d63772d756e26a1));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x00c5972dc829097d95a4eb742cf4badd154479c1661cd7acbcf811a02f80d252), uint256(0x1b9585665bca0ce548089a64f6d8e5a48088f3425813db0559d5a3a14025f220));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x0a6f16dda978357ddc25288dd567ec8041d17fed31c6e402c1b67908d3da7ee9), uint256(0x0829f337c39b12f1658da69aa1b6222888ab6a2d20352bb413d3f7a8d13c580c));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x100426b3b5c3dd03d62fbca80308db1190616dc97f5055b521eb01e4c4d049f1), uint256(0x16966f3d5c0672c0d744698339a70821f6a79965587fa568b0f9e425c776878c));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x0a5f65380858d794582186f4e0fb49cd943cada8aa8ee220c73bc103b18b0084), uint256(0x0f3ae8ac9747ed2412816c9b3a3e063908adda74393308d731f5cae51a35fbfa));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1a1af952c8e9c493e5e061dcaa5c24eb6fac4bd6a2de888731c56f29dedef05d), uint256(0x05e82a31d4b36f7268b5e87754237115e3d014e459364bb23f9c233a40641ab6));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x23a7e9076bef747153d0c522716f64fadd0e64ce54a15f1b3d574e98d0be69c5), uint256(0x2e0a24df365b64b6c93a7365c7736ad0655b48a285e9322d7e20cc8ed5c0fe7d));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2cb1fc5827ff502d034cf16265040b2a2cbe7d3a339885c3999854752bc917a5), uint256(0x0c2dbbc2443806554510271d1e0bdab76c0a5273f3c579b9b86d813a7c226c37));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x01169fc08f64c703e172f5bfc163e5d4c6a8d826bcded2e752a473ef235f2e9c), uint256(0x20df0ec40a975d578e669c083cf4b46217c40105089d08e8f07e8ce2b96dfbe9));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1359522c5e5fdfe987a3f8edab34b86d06333d04fe7daa716ce1cd91fcf667ce), uint256(0x199c4d34146d6af22110eb7892c32d4fb1b406466322dafdd7dbe7498ce18812));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x161ba4d2eabcac0f1689ab2a4ce08a94a497915bbd99dd37995b2daf7a4ac073), uint256(0x015760d0225083b3dbc099c4f7b4f08727aa6138437718896ed7822a0d3c6946));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x17118815e3cf0d1ac542c63561b232c6b9167a3553875104d70d18dd6ce8772f), uint256(0x0ff7d091a23734020764c2776060d32d611446a6433b9de4dfc56cfea43955e0));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x20aee17b21cad84874fc53ad61df38314f4c3886224c2f21d081310984870e99), uint256(0x29871b3aca1106b4badbbd5cdcc72b8086ad226b844f9f10d5b469d4c0d45f06));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0bde45c0754174260d48a78b22328a43eae716ee6037aa7727c54c7ead30c780), uint256(0x295c60e99b79a3f52d73e02327a80a671e69a955167c24c036db0d0f3324f47a));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0c596e782adcc9e4518021d71955a574cab2f284eef6a8d2499394be15bd0837), uint256(0x01a8561d94af9f2626a54bba29e9d42a0627979029e8a998c9a7fafd0465e15d));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x20cbe3b80f3cd1888e3164719024360ef937625a56e24a4fe4f7346fd9ac95e5), uint256(0x2255523b42c3e2ab442b1ea8d6fccd88ea018000ad1febeb5fcc7640c3d20d8a));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x24c659444da8af83d6309247d4bb127ff07a759af5823cecbcdcbaa49094d2b5), uint256(0x1e13b061e2667b3d07592fba8f699ee0f181f7dd01eeb399091f1c52b0ce6ba8));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x24e17ed102a80abf2268b90aebbdcc9160ac551009ec7c6c8f0914fe29f3c679), uint256(0x06b38f17fe18715381501ccafff34e821ecb2c228487383371eeb4c62da6ccb7));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2da6e4b7fa7b9e5b8ce5c106a4b98c4d36de26c383d3653068fd1f18b41967ca), uint256(0x2bdb084201c80eae05c59a9f817110fa0d5a0d68d59afe778cb8b432fe54336e));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x2e29853050fc1f12c85509daf65c7c5fb4770eb667f115bfaa039457622354ae), uint256(0x14d38c38e9c7b2a2d2aed28192d45bc5826b20f110c4f34941e793be6d5bf0fe));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1239d26c5def83707e32b3ae29579017745c905b6a8115965d4bdad3bde92c5e), uint256(0x1c15b7ff290cb65ddbf9a3bba27096f7d2312e897cbdf3ae0e821639a37c5cbe));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1b765d7ff64dc3ec7e9e9bbf95382feba8ec4ca813150c3e0aeb968ed94e6729), uint256(0x0ad66a74df3f94cd0a9799cefbd802373c9239777eb14345bab7e36718a4f3f4));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x1a8efedc7f522116b71caafcb99be3fc4615e896df85dd51c7a5b8d7d5f616c8), uint256(0x065ed06b957bc21f23d0261b3078db2baa5d3298b679387df1dc8d79d6cc3c7a));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x20107db8f0a07ad2d7f7bd4678b7016243c4fcd963980f1b7da89d07ccc6fe5b), uint256(0x092d0fc0504687b65ca7c954571002451d260ceb32244b3fdea90cddb6c9e705));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x049b4f1cf67db8f8fadc997a62d22f862df9872f3b406da77568ed6af59f7533), uint256(0x269347fa4fc1549804c6c51f9134f717157e4c37fb4aa543aae9d708e94697fc));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x06b79c6880ba0014cc181ff2e6ff35f528e433a555f2b04e7efd323a22e90b32), uint256(0x2bd2f45d8df9fff4a9bc37ef295a3bebcf7b8256eccad144d73685089231e2dd));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x25516d7964c6a150033709c47c2dd3aa1b6c55296f4dccca95d2cafa6651a9b7), uint256(0x04694311f950e1adffcf230b69fab7533b9bdbf25439406dfc153dc4715174c2));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x2121b262bfce1204bcee0d01e81ca67a6cf187f200ab4fcd5fed54fae0b60111), uint256(0x2d2d72bfa31219ac0f57f871d8ad20703db85e1175974a5b218c40d493b3e9ae));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x2e947a32fa65cb7a04cb7c1b4a8989d76c6ee6b429e9793e1923673dbb4cb3b7), uint256(0x2d5b7e6ae5d7d16fedba436e07a27bd7097cc2c1dfbab3764622e7d2550208ad));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x28ff53647a48d89c3a43d491fec5dc3ad299b3dd698f70db74707e858db22657), uint256(0x1e2427f306b873672e3d18e0119a542b705dfdda40958c8c70cc45320852e584));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x06441c8fe4316d4ed2dc564e073802900180e6e81d599eb5f359966558c03bed), uint256(0x0305ba1b7b2ef09e2c5936daf50c2548e75292eed44a7885f9a8d9e18307ff48));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x1fde15a8e93e36e53ce9823a4baa2dfc2365c0a1f9997cbecf8b575d661cb7c7), uint256(0x2713407b89b03545aa188b1f01a25b0bd4d3af76ee677c610c2a6f537499cec9));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x2492d9d15e89c65ea47514b2ca27531ad6354c66dd9bab5286b6b343d89eebba), uint256(0x2a7a0dd5cea63c3b86b876ea06a134e83737269e63c501f8d892c41d7df4d7a5));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0dfad9bf4bfa108870b0d4bdf94ec82c32eda69cc7f281980abeba2a92bcdf2e), uint256(0x209debb7d2dd97fd61b44b372e010a3434d6eaa43c29d95eb3eba61997a8962f));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x177b055916b9fb21ce6036f90c2fc4e1d7d8c69c3480de76d7520479a5e306ab), uint256(0x032ee96ae4f748c3b458cda9fbe1c9ac674d292c66a4e4c209406434ca364349));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0cae3b6132a32a06ff367d127bfd97bcbd05425d20fb86a74d5801b31a2012ce), uint256(0x0f1b9045d385d2b169434052198dda5ca9b9d2256b47bace88aee35a9dae2f0d));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x29c0a90b0a9e5481e151691e5e3d9d81a26ffe78164135993dc26b4746988c6d), uint256(0x23c36e334dd4df57f8f9ad55ab1b72f54a048a5dc1c5c93ef5cc8692ab50d6a5));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x08c30c506dbcfc4d91a4208ff57063741f1e7a8aa698936e672b73af6a48d846), uint256(0x1f36bcd1a45c22d3c9fa6dd440bcbacd033ff7bd491fecfd736fbad35be9d43d));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x0b577513270593d6d66d80225283362f064c12d38302bda2e3c7282b628a0647), uint256(0x157a0432f25e7e0c50ae9dc3741e6ee243510bf70d808224d0e59481047bedd2));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x070cdfced195824f9373fb6970290c86b939875199e5d8f7a044e9444a395b8f), uint256(0x1b789f26f2fc16081ef12383bb2a60f4640c121c394f0cca76d294ee06efe277));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x27ad5b3e907971e449a291d129a6e625bea7c8dbc8f8263dbde0a10c22046a4e), uint256(0x21a57beb51a616a8c7aa103ef031cad35cbaeaef772b77ea538e640b9df038ed));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x1e2812fa583e9da73d9782beb69eaf5340f3e74f9cb5a74e7eddec90e41f101d), uint256(0x239fdad543514424cef3655384d92755c1645007215b4066805ff4de0085a63b));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2ecf74f99c0b68fdcf06d509743f516af4b3ad78f92cb436612b9d120a2db574), uint256(0x0c9e00d241b9d502576b091f194cc58af43a4502d447331c41434a6a4e90edf3));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x095a6b5a26dedf874f4b4f8a3fc6b2c49b0519a94288f9af341ef3f2df3b8a77), uint256(0x2aec86fd459d3f3fb9dfd6e33f775d69d89ec565c259fee502d2a03d81e18428));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x07946671561f55e8dda12f519127b44e00e166032177f169603800392166ba0b), uint256(0x22bb0750981c40c1d7d29ce5ec46e9d1310f1e6bee3a6e2580eb0a5c6b39c057));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x09f0ee9ba210a62dd727b7c479f9561610a9b725b282161462b64bc10f52e1fc), uint256(0x1dd4464ce9eb3d1f18d0cd774664e62fd1e9cec9287b2dd1f7d50675d543cef5));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x026faccd4d8252482c7e85f260b1c6c64ae2b74cf4a21c0fed7d26d2fe2ba5aa), uint256(0x2e712938519d5235e1ad658effcd3e1e4f8d8a8cdbf4012ce03ad34e842b710e));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2ea636b9a18e6cd4546952d6770e4f8a59643c9c349921b8284263cbcdf0dca5), uint256(0x0a4a6fd5220a27bcee039ad73a4fd2d20fbf0f294698507d5c3a488bd002b530));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x05cc32cdbcf6d86c850a8a9ce8e2f133d4a87a17190df3ddf14f32dbf1590b7f), uint256(0x0db6eb38f2b48f02d6eb6a97854d0e6908f98470486da9690f705743972e5586));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x02315113abb9f38093a9b8b4dc38328f8d358d17391b21230baa690b66590eae), uint256(0x2eeaba3be6c19b25377ed4ae2053ce998b67c0bb2e4a01108acaebc4bb4c0dfa));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x047111439eda8ed589aae503769788edf6069a1df39e05cc5c6c9edc2cdad89b), uint256(0x19c156001dfaa6d3c31f40b94c5f3bd7cc704ff522b301356aa0faca2b61639f));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x2b944ac197282ce23f4b4a2b9e63cfdee2269c5c5f2c05a1c388aac2d872fc2d), uint256(0x124a19345124e4da939a50b98d9fbacb144d79a9198d283d88bca524e4e5b625));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x06870eecd8b566ca143831c492fee290b675af6f450b2bb2ec37cd0022ede33e), uint256(0x2661fd8b0ad762d40666412281488267710ae48cd13d3ec19900a22ccd733b63));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x0af029dec80042946a4f8dd1a7cf1b968adcf894fbae14d5c789fdf8fb608d79), uint256(0x0ba0061aeb67b2a6f813463f550a6153a209e0f960a434f1c0045c67add64b9a));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x2694d49f8f5989478f823fc0f9fe7a438712618f245ebaddb72c46ded3d39242), uint256(0x20281abb2a1abc539c8dace41ca26a8671af5f5fd6450db2c659343129e9b3d8));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x0dd6dbf9fea55fb35d2cd0c7ef039dd6431ee4d36b740866314f51df67c431e2), uint256(0x15af33eb9cccfc4acbc734ee5f55db6d1687385c96a3fcbdc7e77cc2bca4631c));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x0eecc5e46e5ecd897d901a2e914c95ee2cc2c9f7387acf04493abf14000bb8cc), uint256(0x128fae18cea92e931183b0a90e24da52070c7cdd659572638128c35f2742edd9));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x0c2b0f6a50e472531f99783be5152c49ff91515f7120c81ebf3bec835fe92fb5), uint256(0x2bd8806818ef48122405b75db9b206bbceb124cec4b30f95caa8c229e099acd1));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x0acc5d4cb440bdc6a685a1abfa0d7d0d55f61dcaceb544aa7d6f4453c2a46cf3), uint256(0x29b9695ade15f53511bdccc749b9e7700ce33b468c9b87f9d482a7c75bd2c3d4));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x1ca44b441b99f335ab981d174fca2a53ce6a433bcf67a1f1b6131b5906f1e7e1), uint256(0x090291722c1ebef5a82817a17039dccf5db3c189068d0c962cc186e56e934d00));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x16166d551946cfb2d599fe344430668dcd0ec479a8c2dc8e250db27c9ccaf75c), uint256(0x297308b26e784f48c28b8d72da8d59227cf33786070a0e3c5ceb0208e3b4559a));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x21037865261f65872df95114ba1ea742b610168ae12be2613c2381ec99f62663), uint256(0x12bf3116fe1b37caf5ccd1945f067fdaaebb6ff1bae7ca42f0522ee0df792f59));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x1a01bfa9a7b7b12249f2d6f6fca8e2185fef851b25595dd75a3d0ecaeb83e220), uint256(0x18e5b759a7f05432454e734b8ef6539560905dfaa549d764b41f98ff8353565d));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x1898343165da50b27f5569c602e881f755961892dccb6753b31419042eeb8f9f), uint256(0x226bbabb1cc5810ce99b276e5489a98d409fb374d3d062267ee24ed59d328e66));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x2c45995ecc8f2652547adf25d09434a1084c56400516aabb1a8a17c02e688872), uint256(0x2d6846915cd7bc828469cdcfbb7b9d9e6b886e99940d9f2f640f4a02ddb98aea));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x035482050c4aef3756c84e5dc8f5d91709f3cb0e890e699b653b3a4cc5c16e9d), uint256(0x0a5d13ae6ed0500c9aca49c9140abbb5a0470d64387e5bac6a367ee54171ff3c));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x0804c603ade9137607fed40f0931184d6ab4bac97a5e1ef0e95b51537a49522c), uint256(0x02223af0589750f7e33bd6aa5a28a3a50de112ac375addde5c2afb9e59aa343c));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x0d885f884cd97817c31841aa9108d417be8b031cc5c45c6850c9631dd09cf19d), uint256(0x2c20511a216c02787f5bfd06bee42e4c4d436cb599dd7815602ad5f457ecd123));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x0e4c9ededefd49abeefe91cb5a43daae26624212c5d4937c0d3e29da05ff2a39), uint256(0x1e3e6ccf8127121853436423685fc6054a47f0347b1f44ec95466b75ceadedfd));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x17894d0f1a8c34e5c4b5cd16081994e5747a8b76272f349a4b969bbfea60e5ec), uint256(0x01f30b6abc64eb589b3605c30512d91ded3e55d55b7d882a78f33644453c45a0));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x1c05d0d86c5a8500d05f6b3abdebd4cba8109d5e4ace5544cf5823cd3f122b11), uint256(0x2f22db57d3ad9d87cf88e05227024faed1382e528f03f53397d4b28820db819e));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x2a8ba28cb856bf5716ea9a53134e9d2e048bd37f63ea7873dcf29daf7028238e), uint256(0x12ac2f5d08016b5c82884cbdbd1e50034af821ce6a2b8cd4af39a4effc68d1ac));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x1ed4bd6d255992486a8d1ae317c71d5ca5d34afbf92c3b46850059032b22440d), uint256(0x034379aae27120d03aed227b9ddaf79e4cadaba99f0ef8bb02f67b9cf2948111));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x27921852d9fa9d3b1560395fcbb652009f2081dd5bd08a7a35280325ced21a8d), uint256(0x1fa94e0896ec25cd775f5fddcff994428776066d0d6e395bc04854a5b68b5c9d));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x13d1fa32d1fd8132b2e5df492d599783115049a3b5eda361ca67aebf49660dd7), uint256(0x0e69425ccba18bf0500c3967a93d7488c4f71bb379819b169bde15aa35dc7d04));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x15c8b0b7ac4f594d4b51712bf40461f98a7eb61c75dc26b77b03ce9c3e7bb6c4), uint256(0x2108d9c770bcd745adb5126b7f05313cfe15ab4ae013e2e7c74f75c5af238766));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x2415419055193f10215acaaaa93975bea011917ec00a89efbb2f92ea37b2053c), uint256(0x12787883c626608169f60e233fecac8b1e5f033f05542de94f20d0160b4fbc25));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x134baecc08b05e28fd65d00897da361330fce41d19b864533d88814ac01b4ca9), uint256(0x25e3dd6be5ce432928b0fb9abb49dadd897a15ef67f0374a8e6bfe9b5ea72e30));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x0fb1b6d06f33a85dc052793f84d5eae5434428cfe5b8d3da44c9cc25b01394d7), uint256(0x188cb94ad488ff3b9e00b13f700f86abc3c0b87082565dff27b930ebe9e6e82a));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x05cdbf2addcb38631ba6a6c72353746fc626fdf77b287c7a38b31be8adcaa554), uint256(0x18999b167c09e19238884923b9f999b515992b5efa29c1ae83a8415ef730f96d));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x02d3a29f51917dec4ce05c08e9c58d0901a29ccc2336b837b59f3d7f2f2e7d4e), uint256(0x03a1fd19a40b14d947ed33ae568ac88de6bb37d9530d70ca76d96ff92c11af1b));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x10556353ae2815c92646814cd40e315a804355a6977b04c63be02f739b2d90ff), uint256(0x2064d0d654d52e6c7012b0e2d0fbb7c7e9563b50f50f0127c85a1765ee7c5269));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x2f0cd6ca6f6e0c55e9bb497151df9969f853eac538f3cd000fc752f04eb6908e), uint256(0x3052e4dba0c8f6d21989a9a39c43f5d39f8e4f5a4afac1df0da5dd40fdc72757));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x09de8894f226f1909922360d6b36855d8fdf9c03618511ff8214086205232bff), uint256(0x0933643b994557d7e59ad5036c4533b4db389193e451e93491fc216b9c6580b9));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x0d660c7f3ad2720a036e18b01e19ca76febc81f9d1fa49e303da11fc79e3ebf8), uint256(0x2092c2413a23d252edb96b5b7feef23d29b8bbff7a6c96daf4749d85d234645a));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x2226b3f5cac0fdea6f01337191abf97fec91c882a14eb57660e5035a98148163), uint256(0x22415d7247803c20cb8ad8fdc1c1419b09f5d783d4f02222a8d2bd56e73329d6));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x2a83afa29f7f94f3631ce1046ab008316c0db6a9286f572f32e319c71d274d49), uint256(0x2767d3de8617b2864808deea18296f3c4dee363d0931bc0fd26bcdf14f7879dc));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x2d2113ca0abfed05c439f450d579a194ac49e7f364e620e47be83dfa4aa784ac), uint256(0x2e552ee696e86264194584d9bb78f3685172fde09933fd942d8bd960354b82f9));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x008603abb76041f23812159ce212e28197caf6671f82fdbc5e509ee4015e9980), uint256(0x2f89b383c38c30c28a14664110537d6bbf29188059288e218d0881d1691e3d7e));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x2840d6dc0e1dbe1a1d9c954d7d98a69c68c542e8d1159d1977c901b7427b5b79), uint256(0x1d229486270e63f19fabf904f9bea7331812afd1286a9cc46719e511f10700dc));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x17c73e8e278d30324437e87be554a31e76de7b4e8026d573d85c939e51c98550), uint256(0x1f74b8bfdfda83e6e32f81bd1d7108d45eca087da429c9e72e81e89a95a295ac));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x3030377dad3ceea7772a7fd56ab8c7eb0adb51f170b0489a6487e4e18db6cbb7), uint256(0x05664c0feeef1d6da00be60b390979cd76877efdaa5be414bd0f6feed2b3d889));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x021db4730ea846d5182290bd98d86522e6a6a04f6de916fac0dc379e607c9da9), uint256(0x292cd9cc7a0aa48a91bda94578c31c7588680fb0d4de71dcbc37a90ddd4aeaea));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x2e0e26f5dd3ff71b95b4d387cf6b9d535aabe72a9c7a8ec823c457d4be1fa3d6), uint256(0x02beaac0b5fabb44df3f3be940d0113202cb8487ad9fbe049e001e1180e5ed65));
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
