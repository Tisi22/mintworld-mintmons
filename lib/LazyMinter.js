const ethers = require('ethers')

// These constants must match the ones used in the smart contract.
const SIGNING_DOMAIN_NAME = "Mintmon-Voucher"
const SIGNING_DOMAIN_VERSION = "1"


/**
 * LazyMinter is a helper class that creates NFTVoucher objects and signs them, to be redeemed later by the LazyNFT contract.
 */
class LazyMinter {

  /**
   * Create a new LazyMinter targeting a deployed instance of the LazyNFT contract.
   * 
   * @param {Object} options
   * @param {ethers.Contract} contract an ethers Contract that's wired up to the deployed contract
   * @param {ethers.Signer} signer a Signer whose account is authorized to mint NFTs on the deployed contract
   */
  constructor({ contract, signer }) {
    this.contract = contract
    this.signer = signer
  }

  async createVoucher(tokenId, name, level, experience, image, tp, description, attack1, attack2, attack3, attack4) {
    const name32 = ethers.utils.formatBytes32String(name);
    const type32 = ethers.utils.formatBytes32String(tp);
    const attack1_32 = ethers.utils.formatBytes32String(attack1);
    const attack2_32 = ethers.utils.formatBytes32String(attack2);
    const attack3_32 = ethers.utils.formatBytes32String(attack3);
    const attack4_32 = ethers.utils.formatBytes32String(attack4);

    const voucher = { 
      tokenId, 
      image,
      description,
      data: [name32, type32, attack1_32, attack2_32, attack3_32, attack4_32],
      stats: [level, experience], 
    }
    const domain = await this._signingDomain()
    const types = {
      NFTVoucher: [
        {name: "tokenId", type: "uint256"},
        {name: "image", type: "string"},
        {name: "description", type: "string"},
        {name: "data", type: "bytes32[6]"},
        {name: "stats", type: "uint256[2]"},
      ]
    }
    const signature = await this.signer._signTypedData(domain, types, voucher)
    return {
      ...voucher,
      signature,
    }
  }

  /**
   * @private
   * @returns {object} the EIP-721 signing domain, tied to the chainId of the signer
   */
  async _signingDomain() {
    if (this._domain != null) {
      return this._domain
    }
    const chainId = await this.contract.getChainID()
    this._domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: this.contract.address,
      chainId,
    }
    return this._domain
  }
}

module.exports = {
  LazyMinter
}