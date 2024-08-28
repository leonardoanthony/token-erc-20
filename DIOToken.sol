// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    // Getters
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256); 

    // Functions
    function transfer(address recepient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DIOToken is IERC20 {

    error SaldoInsuficiente();
    error SaldoPermitidoEsgotado();
    error CaiNoTrue();
    error CaiNoFalse();

    string public constant name = "DIO Token";
    string public constant symbol = "DIO";
    uint8 public constant decimals = 18;

    mapping (address => uint256) balances;
    mapping (address => mapping(address => uint256)) allowed;

    uint256 totalSupply_ = 10 ether;

    constructor () {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() external view returns (uint256){
        return totalSupply_;
    }

    function balanceOf(address account) public override view returns (uint256){
        return balances[account];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        if(numTokens >= balances[msg.sender]) revert SaldoInsuficiente();
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    } 

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        if(numTokens >= balances[owner]) revert SaldoInsuficiente(); // Verifica se a carteira possui saldo para transferir
        if(numTokens >= allowed[msg.sender][owner]) revert SaldoPermitidoEsgotado(); // Verifica se o terceiro q está usando a carteira ainda tem saldo disponivel para trasnferir

        balances[owner] = balances[owner]-numTokens; // Diminui saldo da carteira
        allowed[msg.sender][owner] = allowed[msg.sender][owner]-numTokens; // Diminui saldo autorizado para transferir por outra carteira
        balances[buyer] = balances[buyer]+numTokens;// Acrescenta a carteira do recebedor o saldo transferido

        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}