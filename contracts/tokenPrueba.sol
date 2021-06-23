pragma solidity >=0.8.0;



import "../interfaces/IERC20.sol";
import "./ERC20.sol";

contract tokenPrueba is ERC20("TokenPrueba","TKN"){
  constructor () public {
    _mint(msg.sender, 10000 ether);
  }
}
