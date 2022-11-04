const  {mimcSpongecontract}  = require("circomlibjs");
const main = async () => {
    const bytecode = mimcSpongecontract.createCode(0, 32);
    console.log(bytecode);
    console.log(mimcSpongecontract.abi)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });