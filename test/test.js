const { expect } = require("chai");
const hardhat = require("hardhat");
const { ethers } = hardhat;
const { LazyMinter } = require('../lib')

async function deploy() {
  const [minter, redeemer, _] = await ethers.getSigners()

  const BaseNFT = await ethers.getContractFactory("BaseMintmons");
  const basenft = await BaseNFT.deploy();
  const basenftAddress = basenft.address;

  const TokenMWG = await ethers.getContractFactory("MintWorldToken");
  const tokenMWG = await TokenMWG.deploy();
  const tokenMWGAddress = tokenMWG.address;

  let factory = await ethers.getContractFactory("Mintmons", minter)
  const contract = await factory.deploy(minter.address, basenftAddress, tokenMWG.address)

  // the redeemerContract is an instance of the contract that's wired up to the redeemer's signing key
  const redeemerFactory = factory.connect(redeemer)
  const redeemerContract = redeemerFactory.attach(contract.address)
  await basenft.addController(contract.address);
  await tokenMWG.approveSpenderContract(contract.address, 100000000000000);

  return {
    minter,
    redeemer,
    contract,
    redeemerContract,
    basenft,
    tokenMWG,
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

    const TokenMWG = await ethers.getContractFactory("MintWorldToken");
    const tokenMWG = await TokenMWG.deploy();
    const tokenMWGAddress = tokenMWG.address;
    console.log(tokenMWGAddress)

    const signers = await ethers.getSigners();
    const minter = signers[0].address;
    
    const Mintmons = await ethers.getContractFactory("Mintmons");
    const mintmons = await Mintmons.deploy(minter, basenftAddress, tokenMWGAddress);
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

    const TokenMWG = await ethers.getContractFactory("MintWorldToken");
    const tokenMWG = await TokenMWG.deploy();
    const tokenMWGAddress = tokenMWG.address;
    console.log(tokenMWGAddress)

    const signers = await ethers.getSigners();
    const minter = signers[0].address;
    
    const Mintmons = await ethers.getContractFactory("Mintmons");
    const mintmons = await Mintmons.deploy(minter, basenftAddress, tokenMWGAddress);
    await mintmons.deployed();
    console.log(mintmons.address)

    await expect(basenft.addController(mintmons.address))
      .to.emit(basenft, 'ControllerAdded')  // transfer from null address to minter
      .withArgs(mintmons.address)

  });

  it("Should redeem an NFT from a signed voucher", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

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

  it("Should redeem seven NFTs from signed vouchers", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher1 = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")
    const voucher2 = await lazyMinter.createVoucher(2,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")
    const voucher3 = await lazyMinter.createVoucher(3,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")
    const voucher4 = await lazyMinter.createVoucher(4,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")
    const voucher5 = await lazyMinter.createVoucher(5,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")
    const voucher6 = await lazyMinter.createVoucher(6,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")
    const voucher7 = await lazyMinter.createVoucher(7,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")


    const voucherArray = [voucher1, voucher2,voucher3, voucher4, voucher5, voucher6, voucher7];
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
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher1.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher2.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher3.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher4.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher5.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher6.tokenId)
      .to.emit(basenft, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher7.tokenId)

  });

  it("Should show the tokenURI", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

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
    await redeemerContract.redeem(redeemerAddress, voucherArray)

    const tokenURI = await basenft.tokenURI(1);
    console.log(tokenURI)
 
  });

  it("Should Update Metadata of two NFTs", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher1 = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")
    const voucher2 = await lazyMinter.createVoucher(2,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")

    const voucherArray = [voucher1, voucher2];
    console.log("voucherArray:", voucherArray)


    // Get the redeemer's address
    const redeemerAddress = await redeemer.getAddress()

    await redeemerContract.redeem(redeemerAddress, voucherArray)

    const voucher1Metadata = await lazyMinter.createVoucher(1,"Firefy",8,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "ttt", "-","-")
    const voucher2Metadata = await lazyMinter.createVoucher(2,"Stoney",10,7,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "rrr", "-","-")
    const voucherArrayMetadata = [voucher1Metadata, voucher2Metadata]

    // Try to redeem the voucher
    await expect(redeemerContract.metadataUpdateParty(voucherArrayMetadata))
      .to.emit(basenft, 'MintmonMetadataUpdate')
      .withArgs(voucher1Metadata.tokenId)
      .to.emit(basenft, 'MintmonMetadataUpdate')
      .withArgs(voucher2Metadata.tokenId)
  });

  it("Should mint the first Mintmon", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")


    // Get the redeemer's address
    const redeemerAddress = await redeemer.getAddress()

    // Try to redeem the voucher
    await expect(redeemerContract.redeemFirstMintmon(redeemerAddress, voucher))
    .to.emit(basenft, 'Transfer')
    .withArgs('0x0000000000000000000000000000000000000000', redeemerAddress, voucher.tokenId)
  });

  it("Should failed to mint the first Mintmon", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")


    // Get the redeemer's address
    const redeemerAddress = await redeemer.getAddress()

    //Mint the first mintmon
    await redeemerContract.redeemFirstMintmon(redeemerAddress, voucher)

    // Try to mint again the first mintmon
    await expect(redeemerContract.redeemFirstMintmon(redeemerAddress, voucher))
    .to.be.revertedWith("already minted");
  });

  it("Should Update Metadata of two NFTs and send MWG", async function() {
  
    const { contract, redeemerContract, redeemer, minter, basenft, tokenMWG } = await deploy()

    const lazyMinter = new LazyMinter({ contract, signer: minter })
    
    // Create the voucher
    const voucher1 = await lazyMinter.createVoucher(1,"Firefy",5,3,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "-", "-","-")
    const voucher2 = await lazyMinter.createVoucher(2,"Stoney",7,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "-", "-","-")

    const voucherArray = [voucher1, voucher2];
    console.log("voucherArray:", voucherArray)


    // Get the redeemer's address
    const redeemerAddress = await redeemer.getAddress()

    await redeemerContract.redeem(redeemerAddress, voucherArray)
    await tokenMWG.mint(tokenMWG.address, 10000)

    const voucher1Metadata = await lazyMinter.createVoucher(1,"Firefy",8,1,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Fire","A Mintmon","bpmb", "ttt", "-","-")
    const voucher2Metadata = await lazyMinter.createVoucher(2,"Stoney",10,7,"ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi","Stone","A Mintmon","abcd", "rrr", "-","-")
    const voucherArrayMetadata = [voucher1Metadata, voucher2Metadata]

    // Try to redeem the voucher
    await expect(redeemerContract.metadataUpdatePartyAndMWGTransfer(voucherArrayMetadata, 1000))
    .to.emit(basenft, 'MintmonMetadataUpdate')
      .withArgs(voucher1Metadata.tokenId)
    .to.emit(basenft, 'MintmonMetadataUpdate')
      .withArgs(voucher2Metadata.tokenId)
    .to.emit(tokenMWG, 'Transfer')
      .withArgs(tokenMWG.address, redeemerAddress, 1000)
    
  });

});

