// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount 
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 is  IERC20{
    uint public override totalSupply ;
    address public founder ;
    string public name = "BLUEFLAME";
    string public symbol = "BM";
    mapping(address => uint) balance;
    mapping(address => mapping(address => uint)) allowed;
    uint public decimal = 0;

    constructor() {  
        founder = msg.sender; 
        totalSupply = 10000;
        balance[founder] = totalSupply;
    }   

    function balanceOf(address tokenOwner) external view override returns(uint){
        return balance[tokenOwner];
    }
        
    function transfer(address to, uint amount) public override returns(bool success){
        require(balance[msg.sender] >= amount, "not enough token");
        balance[to] = balance[to] + amount;
        balance[msg.sender] = balance[msg.sender] - amount;
        emit Transfer(msg.sender, to, amount);
        return success;
    }

    function approve(address spender, uint NoTokens) external  override returns(bool){
        require(balance[msg.sender] >= NoTokens, "not enough");
        require(NoTokens > 0, "not zero");
        allowed[msg.sender][spender] = NoTokens;
          emit Approval(msg.sender, spender, NoTokens);
        return true;
    } 

 
    function allowance (address owner, address spender) external view override returns(uint){
        return allowed[owner][spender];
    }

    // function all(address owner, address spender) external returns(uint){
    //     return allowance[owner][spender];
    // }


    function transferFrom(address sender,address recipient, uint token) external override returns(bool){
        require(allowed[sender][recipient] >= token, "not allowed");
        require(balance[sender] >= token, "insufficient" );
        balance[sender] = balance[sender] - token;
        balance[recipient] = balance[recipient] + token;
         emit Transfer(sender, recipient , token);
        return true;
    }
}

///this is inheriting the interface soo you have  to override it

