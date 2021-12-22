const hre = require("hardhat");

async function main() {
    const NFT = await hre.ethers.getContractFactory("CryptoQuestDM");
    const nft = await NFT.deploy("https://ipfs.org");
    await nft.deployed();
    console.log("NFT deployed to:", nft.address);
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});