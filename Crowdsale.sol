pragma solidity ^0.4.18;

import "./EtceteraToken.sol";
import "./SafeMath.sol";


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale is Ownable {
  using SafeMath for uint256;
  

  // The token being sold
  EtceteraToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public fundsWallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public amountRaised;
  
  uint256 public tokenCap;
  
  // current bonus applied (where 40% = 1.4)
  uint256 public bonus;
  
  

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    fundsWallet = _wallet;
    tokenCap = token.cap();
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    token.mint(beneficiary, tokens);
    
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
    
    // update state
    amountRaised = amountRaised.add(weiAmount);
  }
  
    function burnTokens(uint256 _value) external onlyOwner returns (bool) {
        token.burn(_value);
    return true;
  }
  
  // @return true if crowdsale is live
  function SaleIsLive() public view returns (bool) {
    return now > startTime && now < endTime;
  }

  // @return true if crowdsale event has ended
  function SaleHasEnded() public view returns (bool) {
    return now > endTime;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (EtceteraToken) {
    return new EtceteraToken();
  }

  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    uint256 bonusrate = (rate.mul(bonus)).div(100);
    return weiAmount.mul(bonusrate);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    fundsWallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

}
