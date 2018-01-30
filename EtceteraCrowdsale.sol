pragma solidity ^0.4.18;

import "./CappedCrowdsale.sol";
import "./RefundableCrowdsale.sol";


contract EtceteraCrowdsale is CappedCrowdsale, RefundableCrowdsale {
    
  bool public founderTokensSent = false;

  function EtceteraCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet) public
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    require(_goal <= _cap);
  }
  
    // Transfer founder, team, associates, reserves and bounty tokens to founder wallet
  function transferFounderTokens() public onlyOwner {
    require(!founderTokensSent);
    token.transfer(fundsWallet, token.founderTokens());
    founderTokensSent = true;
  }
  
  // Changes the rate of the tokensale against 1ETH -> ERA/ETH
  function changeRate(uint256 newRate) public onlyOwner {
    require(newRate > 0);
    rate = newRate;
  }
  
  // Changes the bonus rate of the tokensale in percentage (40% = 140 , 15% = 115 , 10% = 110 , 5% = 105)
  function changeBonus(uint256 newBonus) public onlyOwner {
    require(newBonus >= 100 && newBonus <= 140);
    bonus = newBonus;
  }
  
  // Mint new tokens and send them to specific address
  function mintTokens(address addressToSend, uint256 tokensToMint) public onlyOwner {
    require(tokensToMint > 0);
    require(addressToSend != 0);
    tokensToMint = SafeMath.mul(tokensToMint,1000000000000000000);
    token.mint(addressToSend,tokensToMint);
  }

}