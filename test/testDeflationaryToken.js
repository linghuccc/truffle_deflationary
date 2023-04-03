const BigNumber = require("bignumber.js");
const DeflationaryToken = artifacts.require("DeflationaryToken");

contract("DeflationaryToken", function (accounts) {
  // 测试初始化合约，生成 DFT token，并发送给 owner
  it("should have 1 billion DFT token in owner account", async function () {
    const DFT = await DeflationaryToken.deployed();
    const initialBal = BigNumber(await DFT.balanceOf(accounts[0])).toString();
    const expected = 1e9 * 1e18;

    // 合约 owner 拥有的 DFT Token 数量，应该与初始化 DFT token 数量相同
    assert.equal(initialBal, expected, "Initial balance check failed");
  });

  // 测试 mint 函数的 onlyOwner 属性
  it("should not mint successfully if caller is not owner", async function () {
    const DFT = await DeflationaryToken.deployed();
    const mintAmount = 20 * 1e18;

    // 使用 非 owner 账户 (accounts[1]) mint DFT token 给 accounts[2]
    try {
      await DFT.mint(accounts[2], BigNumber(mintAmount), { from: accounts[1] }),
        assert.fail("Expected revert not received");
    } catch (error) {
      assert.include(error.message, "revert", "Expected revert");
    }
  });

  // 测试 mint 函数
  it("should mint successfully if caller is owner", async function () {
    const DFT = await DeflationaryToken.deployed();
    const mintAmount = 20 * 1e18;

    // mint DFT token 给 accounts[2]
    await DFT.mint(accounts[2], BigNumber(mintAmount));
    const balAcc2 = BigNumber(await DFT.balanceOf(accounts[2])).toString();

    // accounts[2] 拥有的 DFT token 数量，应该与 mint 的数量相同
    assert.equal(balAcc2, mintAmount, "mint check failed");
  });

  // 测试 transfer 函数
  it("should charge fees and burn tokens correctly", async function () {
    const DFT = await DeflationaryToken.deployed();

    // transfer DFT token 给 accounts[3]
    const transferAmount = 30 * 1e18;
    await DFT.transfer(accounts[3], BigNumber(transferAmount));

    const balAcc0 = BigNumber(await DFT.balanceOf(accounts[0])).toString();
    const balAcc1 = BigNumber(await DFT.balanceOf(accounts[1])).toString();
    const balAcc3 = BigNumber(await DFT.balanceOf(accounts[3])).toString();
    const feeAmount = (transferAmount * 500) / 10000;
    const burnAmout = (transferAmount * 500) / 10000;
    const expected0 = BigNumber(1e9 * 1e18)
      .minus(transferAmount)
      .toString();
    const expected3 = transferAmount - feeAmount - burnAmout;

    // accounts[0] 中的 DFT token 数量，应该与 初始化 减去 transfer 的数量相同
    assert.equal(balAcc0, expected0, "Account 0 balance check failed");

    // accounts[1] 在部署时被指定为 feeBeneficiary
    // accounts[1] 中的 DFT token 数量，应该与 feeAmount 相同
    assert.equal(balAcc1, feeAmount, "Account 1 balance check failed");

    // accounts[3] 中的 DFT token 数量，应该与 transfer 数量减去 feeAmount 减去 burnAmout 相同
    assert.equal(balAcc3, expected3, "Account 3 balance check failed");
  });
});
