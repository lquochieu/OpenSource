pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/pedersen.circom";
include "merkleTree.circom";
include "ageCalculation.circom";

template CommitmentHasher() {
    signal input publicKey;
    signal input CCCD;
    signal input sex;
    signal input DoBdate;
    signal input BirthPlace;

    signal output commitment;

    component commitmentHasher = Pedersen(336);
    component publicKeyBits = Num2Bits(160);
    component CCCDBits = Num2Bits(40);
    component sexBits = Num2Bits(8);
    component DoBdateBits = Num2Bits(64);
    component BirthPlaceBits = Num2Bits(64);
    
    publicKeyBits.in <== publicKey;
    CCCDBits.in <== CCCD;
    sexBits.in <== sex;
    DoBdateBits.in <== DoBdate;
    BirthPlaceBits.in <== BirthPlace;

    for (var i = 0; i < 160; i++) {
        commitmentHasher.in[i] <== publicKeyBits.out[i];
    }

    for(var i = 0; i < 40; i++) {
        commitmentHasher.in[i+160] <== CCCDBits.out[i];
    }

    for(var i = 0; i < 8; i++) {
        commitmentHasher.in[i + 200] <== sexBits.out[i];
    }

    for(var i = 0; i < 64; i++) {
        commitmentHasher.in[i + 208] <== DoBdateBits.out[i];
        commitmentHasher.in[i + 272] <== BirthPlaceBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
}

template verifyKYCCredentials(levels) {

	signal input root;
	signal input publicKey;
	signal input CCCD;
    signal input sex;
	signal input DoBdate;
    signal input BirthPlace;

    signal input minAge;
    signal input challenge;

    signal input currentYear;
    signal input currentMonth;
    signal input currentDay;
    
	signal input pathElements[levels];
    signal input pathIndices[levels];

    component hasher = CommitmentHasher();
    hasher.publicKey <== publicKey;
    hasher.CCCD <== CCCD;
    hasher.sex <== sex;
    hasher.DoBdate <== DoBdate;
    hasher.BirthPlace <== BirthPlace;

    component tree = MerkleTreeChecker(levels);
    tree.root <== root;
    tree.leaf <== hasher.commitment;

    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

    // // calculate age
	component age = calculateAgeFromYYYYMMDD();
	age.yyyymmdd <== DoBdate;
	age.currentYear <== currentYear;
	age.currentMonth <== currentMonth;
	age.currentDay <== currentDay;

    // verify age > minAge
    component gte18 = GreaterEqThan(32);
    gte18.in[0] <== age.age;
    gte18.in[1] <== minAge;
    gte18.out === 1;

}

// verifyKYCCredentials(IdOwnershipLevels, IssuerLevels, CountryBlacklistLength)
component main {public [
    publicKey,
    minAge,
    currentYear,
    currentMonth,
    currentDay
]}= verifyKYCCredentials(32);
