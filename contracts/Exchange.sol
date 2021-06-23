pragma solidity >=0.8.0;


// This implementation is not considering fees

import "../interfaces/IERC20.sol";
import "./ERC20.sol";
import "./tokenPrueba.sol";

contract Exchange is ERC20("COINSMOS LP","CLP"){

  event TokenPurchase(address indexed buyer, uint256 indexed eth_sold, uint256 indexed tokens_bought);
  event EthPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed eth_bought);
  event AddLiquidity(address indexed provider, uint256 indexed eth_suministrado, uint256 indexed token_suministrado);
  event RemoveLiquidity(address indexed provider, uint256 indexed eth_removido, uint256 indexed token_retirado);



  address token;


  function setup(address _token) external {
    require (token == address(0));
    require (_token != address(0));
    token = _token;

  }

  function addLiquidity(uint256 min_liquidity, uint256 max_tokens) external payable returns(uint256){
    require (max_tokens > 0);
    require (msg.value > 0);
    uint256 total_liquidity = totalSupply();
    if (total_liquidity > 0){
      require (min_liquidity > 0);
      uint256 eth_reserve = address(this).balance - msg.value;
      uint256 token_reserve = tokenPrueba(token).balanceOf(address(this));
      uint256 token_amount = msg.value*token_reserve/eth_reserve;
      uint256 liquidity_minted = msg.value*total_liquidity/eth_reserve;
      require (max_tokens >= token_amount);
      require (liquidity_minted >= min_liquidity);
      _mint(msg.sender, liquidity_minted);
      if (tokenPrueba(token).transferFrom(msg.sender, address(this), token_amount) == false){
        revert();
      }
      emit AddLiquidity(msg.sender, msg.value, token_amount);
      return liquidity_minted;
    }
    else {
      require (msg.value >= 1000000000);
      uint256 token_amount = max_tokens;
      uint256 initial_liquidity = address(this).balance;
      _mint(msg.sender, initial_liquidity);
      if (tokenPrueba(token).transferFrom(msg.sender, address(this), token_amount) == false){
        revert();
      }
      emit AddLiquidity(msg.sender, msg.value, token_amount);
      return initial_liquidity;

    }
  }

  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens) external returns(uint256,uint256){
      require (amount > 0);
      require (min_eth > 0);
      require (min_tokens > 0);
      uint256 total_liquidity = totalSupply();
      require (total_liquidity > 0);
      uint256 token_reserve = tokenPrueba(token).balanceOf(address(this));
      uint256 eth_amount = amount * address(this).balance / total_liquidity;
      uint256 token_amount = amount * token_reserve / total_liquidity;
      require (eth_amount >= min_eth);
      require (token_amount >= min_tokens);
      _burn(msg.sender, amount);
      payable(msg.sender).transfer(eth_amount);
      if (tokenPrueba(token).transfer(msg.sender, token_amount) == false){
        revert();
      }

      emit RemoveLiquidity(msg.sender, eth_amount, token_amount);
      return (eth_amount, token_amount);
  }

  function ethToTokenSwapInput(uint256 min_tokens) external payable returns(uint256) {
    return ethToTokenInput(msg.value, min_tokens, msg.sender, msg.sender);
  }

  function ethToTokenSwapOutput(uint256 tokens_bought) external payable returns(uint256){
    return ethToTokenOutput(tokens_bought, msg.value, msg.sender, msg.sender);
  }

  function ethToTokenInput(uint256 eth_sold, uint256 min_tokens, address buyer, address recipient) internal returns(uint256){
    require (eth_sold > 0);
    require (min_tokens > 0);
    uint token_reserve = tokenPrueba(token).balanceOf(address(this));
    uint tokens_bought = getInputPrice(eth_sold, address(this).balance - eth_sold, token_reserve);
    assert (tokens_bought >= min_tokens);
    if (tokenPrueba(token).transfer(recipient, tokens_bought) == false){
      revert();
    }
    emit TokenPurchase(buyer, eth_sold, tokens_bought);
    return tokens_bought;

  }

  function ethToTokenOutput(uint256 tokens_bought, uint256 max_eth, address buyer, address recipient) internal returns(uint256){
    require (tokens_bought > 0);
    require (max_eth > 0);
    uint256 token_reserve = tokenPrueba(token).balanceOf(address(this));
    uint256 eth_sold = getOutputPrice(tokens_bought, address(this).balance - max_eth, token_reserve);
    uint256 eth_refund = max_eth - eth_sold;
    if (eth_refund > 0){
        payable(buyer).transfer(eth_refund);
    }
    if (tokenPrueba(token).transfer(recipient, tokens_bought) == false){
      revert();
    }
    return eth_sold;


  }

  function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) internal pure returns(uint256){
    require (input_reserve > 0);
    require (output_reserve > 0);
    uint256 numerator = input_amount*output_reserve;
    uint256 denominator = input_reserve + input_amount;
    return numerator / denominator;
  }

  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) internal pure returns(uint256){
    require(input_reserve > 0);
    require(output_reserve > 0);
    uint256 numerator = input_reserve*output_amount;
    uint256 denominator = output_reserve-output_amount;
    return numerator/denominator;
  }

  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth) external returns(uint256){
    return tokenToEthInput(tokens_sold, min_eth, msg.sender, msg.sender);
  }

  function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens) external returns(uint256){
    return tokenToEthOutput(eth_bought, max_tokens, msg.sender, msg.sender);
  }

  function tokenToEthInput(uint256 tokens_sold, uint256 min_eth, address buyer, address recipient) internal returns(uint256){
    require (tokens_sold > 0);
    require (min_eth > 0);
    uint256 token_reserve = tokenPrueba(token).balanceOf(address(this));
    uint256 eth_bought = getInputPrice(tokens_sold, token_reserve, address(this).balance);
    assert (eth_bought >= min_eth);
    payable(recipient).transfer(eth_bought);
    if (tokenPrueba(token).transferFrom(buyer, address(this), tokens_sold) == false){
      revert();
    }
    emit EthPurchase(buyer, tokens_sold, eth_bought);
    return eth_bought;
  }

  function tokenToEthOutput(uint256 eth_bought, uint256 max_tokens, address buyer, address recipient) internal returns(uint256){
    require(eth_bought > 0);
    uint256 token_reserve = tokenPrueba(token).balanceOf(address(this));
    uint256 tokens_sold = getOutputPrice(eth_bought, token_reserve, address(this).balance);

    require(max_tokens>= tokens_sold);
    payable(recipient).transfer(eth_bought);
    if (tokenPrueba(token).transferFrom(buyer, address(this), tokens_sold) == false){
      revert();
    }
    emit EthPurchase(buyer, tokens_sold, eth_bought);
    return tokens_sold;

  }

  function tokenAddress() external view returns(address){
    return token;
  }



}
