// SPDX-License-Identifier: ISC
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeflationaryToken is ERC20Burnable, Ownable {
    /* ========== 全局参数 ========== */
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 交易手续费参数
    // isFee决定交易是否收费；transactPercent为收费百分比，以万分之一为单位；feeBeneficiary为接收交易手续费地址
    // 初始设置收取交易手续费，费率为5%
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    bool public isFee = true;
    uint256 public feePercent = 500;
    address public feeBeneficiary;

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 交易燃烧参数
    // isBurn决定交易是否燃烧；burnPercent为燃烧百分比，以万分之一为单位
    // 初始设置交易燃烧，费率为5%
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    bool public isBurn = true;
    uint256 public burnPercent = 500;

    /* ========== 构造函数 ========== */
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 创建合约时运行（只运行一次）
    // 生成10亿 DFT token，并发送给合约创建者
    // 设置接收交易手续费地址
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    constructor(address _feeReceiver) ERC20("Deflationary Token", "DFT") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        feeBeneficiary = _feeReceiver;
    }

    /* ========== 设置函数 ========== */
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 设置交易手续费，只有合约拥有者才能修改
    // 如要取消交易手续费，则设置 _feePercent = 0
    // _feePercent按万分之一计算，0 <= _feePercent <= 10000
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function setFee(uint256 _feePercent, address _newReceiver) external onlyOwner {
        if (_feePercent == 0)
            isFee = false;
        else {
            isFee = true;
            feePercent = _feePercent;
            feeBeneficiary = _newReceiver;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 设置交易燃烧，只有合约拥有者才能修改
    // 如要取消交易燃烧，则设置 _burnPercent = 0
    // _burnPercent按万分之一计算，0 <= _burnPercent <= 10000
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function setBurn(uint256 _burnPercent) external onlyOwner {
        if (_burnPercent == 0)
            isBurn = false;
        else {
            isBurn = true;
            burnPercent = _burnPercent;
        }
    }

    /* ========== 功能函数 ========== */
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 增发功能，只有合约拥有者才能增发
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 销毁功能在ERC20Burnable.sol里面定义
    // burn(uint256 amount)销毁function caller的token amount
    // burnFrom(address account, uint256 amount)销毁function caller被allow spend的token amount
    /////////////////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 运算函数
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function getAmount(uint256 _amount, uint256 _percent) internal pure returns (uint256) {
        return _amount * _percent / 10000;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 复写transfer函数，以实现交易销毁及交易收取手续费功能
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function transfer(address to, uint256 amount) public override returns (bool) {
        address _fromAddr = _msgSender();
        uint256 _feeAmount;
        uint256 _burnAmount;
        uint256 _remainingAmount;

        if (isFee) {
            _feeAmount = getAmount(amount, feePercent);
            _transfer(_fromAddr, feeBeneficiary, _feeAmount);
        }

        if (isBurn) {
            _burnAmount = getAmount(amount, burnPercent);
            _burn(_fromAddr, _burnAmount);
        }

        _remainingAmount = amount - _feeAmount - _burnAmount;
        _transfer(_fromAddr, to, _remainingAmount);

        return true;
    }
}