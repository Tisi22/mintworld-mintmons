const { expect } = require("chai");
const hardhat = require("hardhat");
const { ethers } = hardhat;
const { LazyMinter } = require('../lib')

async function deploy() {
  const [minter, redeemer, _] = await ethers.getSigners()

  const BaseNFT = await ethers.getContractFactory("BaseMintmons");
  const basenft = await BaseNFT.deploy();
  const basenftAddress = basenft.address;

  let factory = await ethers.getContractFactory("Mintmons", minter)
  const contract = await factory.deploy(minter.address, basenftAddress)

  // the redeemerContract is an instance of the contract that's wired up to the redeemer's signing key
  const redeemerFactory = factory.connect(redeemer)
  const redeemerContract = redeemerFactory.attach(contract.address)
  await basenft.addController(contract.address);

  return {
    minter,
    redeemer,
    contract,
    redeemerContract,
    basenft,
  }
}

describe("Deploy", function() {
  it("Should deploy BaseMintmons", async function() {
  
    const BaseNFT = await ethers.getContractFactory("BaseMintmons");
    const basenft = await BaseNFT.deploy();
    await basenft.deployed();
  });

  it("Should deploy Mintmons", async function() {
  
    const BaseNFT = await ethers.getContractFactory("BaseMintmons");
    const basenft = await BaseNFT.deploy();
    const basenftAddress = basenft.address;
    console.log(basenftAddress)

    const signers = await ethers.getSigners();
    const minter = signers[0].address;
    
    const Mintmons = await ethers.getContractFactory("Mintmons");
    const mintmons = await Mintmons.deploy(minter, basenftAddress);
    await mintmons.deployed();
    console.log(mintmons.address)

  });

});

describe("Mintmons", function() {
  
  it("Should add a controller", async function() {
  
    const BaseNFT = await ethers.getContractFactory("BaseMintmons");
    const basenft = await BaseNFT.deploy();
    const basenftAddress = basenft.address;
    console.log(basenftAddress)

    const signers = await ethers.getSigners();
    const minter = signers[0].address;
    
    const Mintmons = await ethers.getContractFactory("Mintmons");
    const mintmons = await Mintmons.deploy(minter, basenftAddress);
    await mintmons.deployed();
    console.log(mintmons.address)

    await expect(basenft.addController(mintmons.address))
      .to.emit(basenft, 'ControllerAdded')  // transfer from null address to minter
      .withArgs(mintmons.address)

  });

  it("Should redeem an NFT from a signed voucher", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")
    console.log("Created voucher:", voucher)

    const voucherArray = [voucher];
    console.log("voucherArray:", voucherArray)

    // Get the minter's address
    const minterAddress = await minter.getAddress()
    console.log("Minter address:", minterAddress)

    // Get the redeemer's address
    const redeemerAddress = await redeemer.getAddress()
    console.log("Redeemer address:", redeemerAddress)

    // Try to redeem the voucher
    await expect(redeemerContract.redeem(redeemerAddress, voucherArray))
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher.tokenId)
  });
   
});

