pragma solidity ^0.4.20;

import 'github.com/oraclize/ethereum-api/oraclizeAPI.sol';
import './veros.sol';

contract oracle is usingOraclize{
    uint public price;

    function __callback(bytes32 myid, string result){

        if(msg.sender != oraclize_cbAddress()) throw;

        price = parseInt(result, 18);
        getPrice();
    }

    function getPrice() public payable{

        if(oraclize_getPrice("URL") > this.balance){
            return;
        } else{
            oraclize_query(86400, "URL", "json(https://api.coinmarketcap.com/v1/ticker/veros/?convert=ETH).[0].price_eth");
        }
    }
}

contract Crowdsale is OwnableWithDAO, oracle, StandardToken{
    using SafeMath for uint;

    DAOToken public token;
    address public wallet; //кошелек сбора средств
    uint public coin;

    address public RezerveFond;



    function Crowdsale() {
        token = new DAOToken();
        coin = 1000000;
        getPrice();
        RezerveFond = 0x33A8a7FEe71f48876c79717cc44fB6Db4dA48975;
        wallet = RezerveFond;

    }

    //Продажа
    function changeTokens()  payable {
        require(!blackList[msg.sender]);

        uint tokens = msg.value.mul(coin).div(price);
        uint rest = 0;
        // в случае если начислили эфиров больше,
        // чем есть на контракте, то продадим оставшиеся токены и вернем сдачу
        if(tokenBalance() < tokens){
            tokens = tokenBalance();
            rest = msg.value.sub(tokens.mul(price).div(coin));
            msg.sender.transfer(rest);
        }
        token.transfer(msg.sender, tokens);
        wallet.transfer(this.balance);
    }

    function() external payable {
        changeTokens();

    }

    function tokenBalance() returns (uint) {
        return token.balanceOf(address(this));
    }

}

