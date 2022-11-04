pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/pedersen.circom";
// include "../archive_and_obsolete/circuits/credential.circom";
// include "../archive_and_obsolete/circuits/idOwnershipGenesis.circom";
// include "../archive_and_obsolete/circuits/ageCalculation.circom";

template testHash() {
    signal input publicKey;
    signal input nullifierHash;
    signal output commitment;
    component commitmentHasher = Pedersen(160);
    component publicKeyBits = Num2Bits(160);
    publicKeyBits.in <== publicKey;

    for (var i = 0; i < 160; i++) {
        commitmentHasher.in[i] <== publicKeyBits.out[i];
    }
    commitment <== commitmentHasher.out[0];
    log(commitment);
    commitment === nullifierHash;
}


component main = testHash();
