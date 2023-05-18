const { expect } = require("chai");
const hardhat = require("hardhat");
const { ethers } = hardhat;
const { LazyMinter } = require('../lib')

async function deploy() {
  const [minter, redeemer, _] = await ethers.getSigners()

  let factory = await ethers.getContractFactory("Mintmons", minter)
  const contract = await factory.deploy(minter.address)

  // the redeemerContract is an instance of the contract that's wired up to the redeemer's signing key
  const redeemerFactory = factory.connect(redeemer)
  const redeemerContract = redeemerFactory.attach(contract.address)

  return {
    minter,
    redeemer,
    contract,
    redeemerContract,
  }
}

describe("Mintmons", function() {
  it("Should deploy", async function() {
    const signers = await ethers.getSigners();
    const minter = signers[0].address;

    const LazyNFT = await ethers.getContractFactory("Mintmons");
    const lazynft = await LazyNFT.deploy(minter);
    await lazynft.deployed();
  });

  it("Should redeem an NFT from a signed voucher", async function() {
    const { contract, redeemerContract, redeemer, minter } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    const voucher1 = await lazyMinter.createVoucher(1,"Firefy","5","ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon")
    const voucher2 = await lazyMinter.createVoucher(2,"Firefy","5","ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon")

    const voucherArray = [voucher1, voucher2]
    console.log(voucherArray)

    await expect(redeemerContract.redeem(redeemer.address, voucherArray))
      .to.emit(contract, 'Transfer')  // transfer from null address to minter
      .withArgs('0x0000000000000000000000000000000000000000', redeemer.address, voucher1.tokenId)

      .to.emit(contract, 'Transfer')  // transfer from null address to minter
      .withArgs('0x0000000000000000000000000000000000000000', redeemer.address, voucher2.tokenId)
    });

});
