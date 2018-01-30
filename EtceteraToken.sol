pragma solidity ^0.4.18;

import "./MintableToken.sol";



contract EtceteraToken is MintableToken {

  string public constant name = "Etcetera Token"; 
  string public constant symbol = "ERA"; 
  uint8 public constant decimals = 18;
  
  uint256 public constant founderTokens = 3000000000000000000000000; //3M tokens

    function EtceteraToken() public {
    totalSupply_ = founderTokens;
    balances[msg.sender] = founderTokens;
    Transfer(0x0, msg.sender, founderTokens);
    }

}