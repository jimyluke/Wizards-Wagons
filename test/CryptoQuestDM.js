const { expect } = require("chai");
const { BigNumber } = require("ethers");

describe("Crypto Quest contract testing", function() {
    let Token;
    let cryptoQuest;

    beforeEach(async function () {
        const [owner] = await ethers.getSigners();
        Token = await ethers.getContractFactory("CryptoQuestDM");

        cryptoQuest = await Token.deploy("CryptoquestDM", "CQDM", "https://ipfs.org", "https://ipfs.org");
    });

    describe("Deployment", function () {

        it("Deployment should assign all the constants", async function () {
            // expect(await cryptoQuest.MAX_ITEMS()).to.equal(5000);
            // expect(await cryptoQuest.MAX_MINT()).to.equal(10);
            expect(await cryptoQuest.getBaseURI()).to.equal("https://ipfs.org");
        });

        it("It should get contract balance", async function () {
            expect(await cryptoQuest.getContractBalance()).to.equal(0);

        });

        it("It should be only called by owner", async function () {
            expect(cryptoQuest.reveal()).to.not.reverted;
        });

        it("Checking prescale cost", async function () {
            expect(await cryptoQuest.getCurrentCost()).to.equal(ethers.utils.parseEther('0.05'));
        });


        // it("Checking minting function", async function () {
        //     expect(await cryptoQuest.mint(1)).to.not.reverted;
        // });

        it("Should check white list user", async function () {
            let user = "0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199";
            expect(await cryptoQuest.isWhitelisted(user)).to.equal(false);
        });

        it("Should check user owned tokens", async function () {
            let user = "0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199";
            expect(await cryptoQuest.walletOfOwner(user)).to.have.lengthOf(0);
        });

        // it("Should return tokens uri", async function () {
        //     expect(await cryptoQuest.tokenURI(1)).to.equal(0);
        // });

        it("Should check current cost", async function () {
            expect(await cryptoQuest.getCurrentCost()).to.equal(ethers.utils.parseEther('0.05'));
        });
        // it("It should open/close minting", async function () {
        //     expect(await cryptoQuest.batch()).to.equal(0);
        //     expect(await cryptoQuest.sale()).to.equal(false);
        //     await cryptoQuest.toggleSale()
        //     expect(await cryptoQuest.batch()).to.equal(1);
        //     expect(await cryptoQuest.sale()).to.equal(true);
        //
        //     expect(
        //         cryptoQuest.connect(ether1).toggleSale()
        //     ).to.be.revertedWith("Ownable: caller is not the owner");
        //
        // });

        // it("It should change the price for minting", async function () {
        //     expect(await cryptoQuest.basePrice()).to.equal(ethers.utils.parseEther('0.07'));

        //     await cryptoQuest.changePrice(ethers.utils.parseEther('0.06'))

        //     expect(await cryptoQuest.basePrice()).to.equal(ethers.utils.parseEther('0.06'));

        //     expect(
        //         cryptoQuest.connect(ether1).changePrice(ethers.utils.parseEther('0.06'))
        //     ).to.be.revertedWith("Ownable: caller is not the owner");
        // })
    });

})
