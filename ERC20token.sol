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
        
    function transfer(address to, uint amount) public override virtual returns(bool success){
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


    function transferFrom(address sender,address recipient, uint token) public override virtual returns(bool){
        require(allowed[sender][recipient] >= token, "not allowed");
        require(balance[sender] >= token, "insufficient" );
        balance[sender] = balance[sender] - token;
        balance[recipient] = balance[recipient] + token;
         emit Transfer(sender, recipient , token);
        return true;
    }
}

///this is inheriting the interface soo you can to override it or just implement it like that 
    

contract ICO is ERC20{
    address public manger;
    address public desposit;
    uint tokenPrice = 0.1 ether ;
    uint TokenCap = 300;
    uint amountRaised ;
    uint tradeTime = Icoend + 3600;
    uint minPrice = 10 ether;
    uint maxPrice = 0.1 ether;
    uint IcoStart  = block.timestamp;
    uint Icoend = block.timestamp + 120;

    enum status {Bresumed,Aresumed, ruuning, end}

    event investLog(address investor, uint amount, uint NoToken);

    status public AllStatus;

    constructor(address payable _desposit){
        desposit = _desposit;
        manger = msg.sender;
         AllStatus = status.Bresumed;
    }

    modifier onlyOwner() {
        require(msg.sender == manger, "not manger");
        _;
    }
   
    function resume() external onlyOwner{
        AllStatus = status.ruuning;
    }

    function halted() external onlyOwner{
        AllStatus = status.end;
    } 

    function ChangeDesposit(address payable _Cdesposit) external onlyOwner{
        desposit = _Cdesposit;
    }  

    function getState() public view returns(status){
        if(AllStatus == status.end){
            return status.end;
        }else if(block.timestamp < IcoStart){
            return status.Bresumed;
        }else if(block.timestamp >= IcoStart && block.timestamp <= Icoend){
            return status.ruuning;
        }else{
            return status.Aresumed;
        }
    }

    function invest() public payable returns(bool){
        AllStatus = getState();
        require(AllStatus == status.ruuning, "not in the right state");
        require(TokenCap >= msg.value, "no longer in section");
        amountRaised = amountRaised + msg.value;
        require(msg.value >= minPrice && maxPrice <= msg.value, "not in range to invest");
        uint amountToken = msg.value/tokenPrice;
        balance[msg.sender] + amountToken;
        balance[founder] - amountToken;
        (bool sent,) = payable(desposit).call{value: msg.value}("");
        emit investLog(msg.sender, msg.value, amountToken);
        return sent;
    }

    function burn() external returns(bool){
        AllStatus = getState();
        require(AllStatus == status.Aresumed, "finished the distribution");
        balance[founder] = 0;
        return true;
    } 

    function transfer(address to ,uint tokens) public override returns(bool success){
        require(block.timestamp > tradeTime ,"not now");
        super.transfer(to, tokens);  //can use either super which refers to the parent contract or the name of the contract
        return success;
    } 

    function transferFrom(address owner,address spender, uint token) public override returns(bool){
        require(block.timestamp > tradeTime ,"not now");
        super.transferFrom(owner, spender, token);
        return true;
    }

    receive() external payable{
        invest();
    }

} 

