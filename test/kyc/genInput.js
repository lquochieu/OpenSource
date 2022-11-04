const { buildPedersenHash, buildBabyjub } = require("circomlibjs");
const { toBufferLE, toBigIntLE, toBigIntBE } = require("bigint-buffer");
const MerkleTree = require("fixed-merkle-tree");
const { randomBytes } = require("crypto");

let pedersen;
let babyJub;
let F;
let tree;

function hash(msg) {
  return F.toObject(babyJub.unpackPoint(pedersen.hash(msg))[0]);
}

function randomBigInt(n) {
  return toBigIntLE(randomBytes(n));
}

function getDoB() {
  let DoByear = 2001;
  let DoBmonth = 8;
  let DoBday = 25;
  return BigInt(DoByear * 10000 + DoBmonth * 100 + DoBday);
}

function getBirthPlace() {
  let codeCountry = 84;
  let codeProvice = 26;
  let codeDistrict = 5;
  return BigInt(codeCountry * 10000 + codeProvice * 100 + codeDistrict);
}

function generateDeposit() {
  let deposit = {
    publicKey: randomBigInt(20),
    CCCD: randomBigInt(5),
    sex: 1n,
    DoBdate: getDoB(),
    BirthPlace: getBirthPlace()
  };

  const nullifierImage = Buffer.concat([
    toBufferLE(deposit.publicKey, 20),
    toBufferLE(deposit.CCCD, 5),
    toBufferLE(deposit.sex, 1),
    toBufferLE(deposit.DoBdate, 8),
    toBufferLE(deposit.BirthPlace, 8),
  ]);

  deposit.commintment = hash(nullifierImage);
  return deposit;
}

const main = async () => {
  pedersen = await buildPedersenHash();
  babyJub = await buildBabyjub();
  F = babyJub.F;
  tree = new MerkleTree(32);

  let dateObj = new Date();
  let month = dateObj.getUTCMonth() + 1; //months from 1-12
  let day = dateObj.getUTCDate();
  let year = dateObj.getUTCFullYear();

  const deposit = generateDeposit();

  // console.log(hash(toBufferLE(deposit.publicKey, 20)))
  tree.insert(deposit.commintment);
  const { pathElements, pathIndices } = tree.path(0);

  // console.log(deposit.nullifier);

  const input = {
    root: tree.root(),
    nullifierHash: deposit.commintment,
    publicKey: deposit.publicKey,
    CCCD: deposit.CCCD,
    sex: deposit.sex,
    DoBdate: deposit.DoBdate,
    BirthPlace: deposit.BirthPlace,

    minAge: 18,
    challenge: 100,
    currentYear: year,
    currentMonth: month,
    currentDay: day,
    pathElements: pathElements,
    pathIndices: pathIndices,
  };
  console.log(input);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
