require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",

  networks: {
    mainnet: {
      url: process.env.INFURA,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
