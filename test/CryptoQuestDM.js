const { expect } = require("chai");
const { BigNumber } = require("ethers");

beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("CryptoQuestDM");

    const cyrptoQuest = await Token.deploy("https://ipfs.org");
});

describe("Crypto Quest Token contract", function () {

    it("Deployment should assign all the constants", async function () {
        expect(await cyrptoQuest.MAX_ITEMS()).to.equal(5000);
        expect(await cyrptoQuest.MAX_MINT()).to.equal(10);
        expect(await cyrptoQuest.baseTokenURI()).to.equal("https://ipfs.org");
    });

    it("It should open/close minting", async function () {
        expect(await cyrptoQuest.batch()).to.equal(0);
        expect(await cyrptoQuest.sale()).to.equal(false);
        await cyrptoQuest.toggleSale()
        expect(await cyrptoQuest.batch()).to.equal(1);
        expect(await cyrptoQuest.sale()).to.equal(true);

        expect(
            cyrptoQuest.connect(ether1).toggleSale()
        ).to.be.revertedWith("Ownable: caller is not the owner");

    })

    it("It should change the price for minting", async function () {
        expect(await cyrptoQuest.basePrice()).to.equal(ethers.utils.parseEther('0.07'));

        await cyrptoQuest.changePrice(ethers.utils.parseEther('0.06'))

        expect(await cyrptoQuest.basePrice()).to.equal(ethers.utils.parseEther('0.06'));

        expect(
            cyrptoQuest.connect(ether1).changePrice(ethers.utils.parseEther('0.06'))
        ).to.be.revertedWith("Ownable: caller is not the owner");
    })
});