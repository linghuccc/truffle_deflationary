const Migrations = artifacts.require("DeflationaryToken");

module.exports = function (deployer) {
  deployer.deploy(Migrations, "0x62098C55C94FFBe8610D548Ef77D731556bfF20E");
};
