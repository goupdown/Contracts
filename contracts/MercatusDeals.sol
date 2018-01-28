pragma solidity ^0.4.15;

contract MercatusDeals {
  uint dealsCount;
  address public be = 0x10367bD202112F862d715D093C0B78E26BEcdc9C;
  enum state { paid, verified, halted, finished}
  enum currencyType { USDT, BTC, ETH}
  struct Deal {
    state  currentState;
    uint  start;
    uint  deadline;
    uint  maxLoss;
    uint  startBalance;
    uint  targetBalance;
    uint  amount;
    currencyType  currency;
    string  investor;
    address  investorAddress;
    string  trader;
    address  traderAddress;
  }
  Deal[] public deals;
  function MercatusDeals() payable{}
  modifier onlyBe() {
   require(msg.sender == be);
   _;
 }
  modifier inState(uint dealId, state s) {
   require(deals[dealId].currentState == s);
   _;
 }
 function getState(uint dealId) public constant returns (uint)  {
   return uint(deals[dealId].currentState);
 }
 function getStart(uint dealId) public constant returns (uint)  {
   return deals[dealId].start;
 }
 function setVerified(uint dealId) public  onlyBe inState(dealId, state.paid) {
     deals[dealId].currentState = state.verified;
}

 function setHalted(uint dealId) public  onlyBe {
     require(deals[dealId].currentState == state.paid || deals[dealId].currentState == state.verified);
     deals[dealId].traderAddress.transfer(deals[dealId].amount);
     deals[dealId].currentState = state.halted;
}
 function setFinished(uint dealId, uint finishAmount) public  onlyBe inState(dealId, state.verified) {
     if(finishAmount <= deals[dealId].startBalance){
       deals[dealId].investorAddress.transfer(deals[dealId].amount);
     }else if(finishAmount>deals[dealId].targetBalance){
       deals[dealId].traderAddress.transfer(deals[dealId].amount);
     }
     else{
       deals[dealId].traderAddress.transfer(((finishAmount-deals[dealId].startBalance)/(deals[dealId].targetBalance-deals[dealId].startBalance))*deals[dealId].amount);
       deals[dealId].amount = deals[dealId].amount - ((finishAmount-deals[dealId].startBalance)/(deals[dealId].targetBalance-deals[dealId].startBalance))*deals[dealId].amount;
       deals[dealId].investorAddress.transfer(deals[dealId].amount);
     }
     deals[dealId].currentState = state.finished;
}
    function getDealsCount() public constant returns (uint){
        return deals.length;
    }
function () public payable {
}
    function makeDeal(uint _duration, uint _maxLoss, uint _startBalance, uint _targetBalance, uint _amount,  string _investor, address _investorAddress, string _trader, address _traderAddress, uint offer, uint _currency)
    payable public {
      require( _currency >= 0 &&  _currency < 2  );
      require(msg.value == _amount);
        deals.push(Deal({
            currentState: state.paid,
            start: now,
            deadline: 0,
            maxLoss: _maxLoss,
            startBalance: _startBalance,
            targetBalance: _targetBalance,
            amount: _amount,
            currency: currencyType(_currency),
            investor: _investor,
            investorAddress: _investorAddress,
            trader: _trader,
            traderAddress: _traderAddress
          }));
          deals[deals.length-1].deadline = now +  _duration * 86400;
        spawnInstance(msg.sender,deals.length-1, now, offer);
    }
    event spawnInstance(address indexed from, uint indexed dealId, uint start, uint offer);
}