// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RebaseToken is ERC20 {
  error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

  uint256 private constant PRECISION_FACTOR = 1e18;
  uint256 private s_interestRate = 5e10;
  mapping(address => uint256) private s_userInterestRate;
  mapping(address =>uint256) private s_userLastUpdatedTimestamp;

  event InterestRateChanged(uint256 newInterestRate);

  constructor() ERC20("RebaseToken", "RBT") {
    
  }
  
  function setInterestRate(uint256 _interestRate) external {
    if (_interestRate > s_interestRate) {
      revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _interestRate);
    }
    s_interestRate = _interestRate;
    emit InterestRateChanged(_interestRate);
  }

  function mint(address _to, uint256 _amount) external {
    _mintAccruedInterest(_to);
    s_interestRate[_to] = s_interestRate;
    _mint(_to, _amount);
  } 

  function balanceOf(address _user) public view override returns (uint256) {
    return super.balanceOf(_user) * _getAccruedInterest(_user) / PRECISION_FACTOR;
  }

  function _getAccruedInterest(address _user) internal view returns (uint256) {
    uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
   linearInterest = PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed);
  }
  function _mintAccruedInterest(address _to) internal {

  }

  function getUserInterestRate(address _user) external view returns (uint256) {
    return s_userInterestRate[_user];
  }
}
