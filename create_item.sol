pragma solidity ^0.7.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

// contract to be paired with item creation
contract Item {
    uint public priceInWei;
    uint public index;
    uint public pricePaid;
    
    SupplyChain parentContract;
    
    // Constructor variables that are populated during each contract instance
    constructor(SupplyChain _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
    
    // Receive function that must be paired with fallback function in order for it to work as of 0.6.0
    receive() external payable {
        require(pricePaid == 0, "This item has already been paid for");
        require(priceInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
       (bool success, ) = address(parentContract).call{value:(msg.value)}(abi.encodeWithSignature("payforItem(uint256),index"));
       require(success, "The transaction wasn't successful,cancelling");
    }
    
    fallback() external {
        
    }
}

contract SupplyChain is Ownable {

enum ItemStateChange {Created,Paid,Delivered}

// Struct used in combination with a variable for the uint to make a mapping
struct S_Item {
    Item _item;
    string _identifier;
    uint _itemPrice;
    SupplyChain.ItemStateChange _state;
}

// Mapping used to couple each itemIndex with it's respective struct
mapping(uint => S_Item) public items;

uint itemIndex;

event SupplyChainStep(address indexed _from, address _to, string _identifier, uint _itemPrice, address itemAddress);

event SupplyPaymentandDelivery(address indexed _from, address _to, uint indexed itemIndex, address itemAddress);

// Creates the the item leveraging the S_Item struct defined earlier
function createOrder(string memory _identifier, uint _itemPrice) public onlyOwner{
    Item item = new Item(this, _itemPrice, itemIndex);
    items[itemIndex]._item = item;
    items[itemIndex]._identifier = _identifier;
    items[itemIndex]._itemPrice = _itemPrice;
    items[itemIndex]._state = ItemStateChange.Created;
    itemIndex++;
    emit SupplyChainStep(msg.sender,address(this), _identifier, _itemPrice, address(item));
}

// Ensures that only an item that has been created can be paid for as well as updates the state to "paid" after the transaction
function payforItem(uint itemIndex) public payable {
    require(items[itemIndex]._state == ItemStateChange.Created, "We have an issue processing this request, your item might be further in the chain");
    require(items[itemIndex]._itemPrice == msg.value, "Only full payments are accepted!");
    items[itemIndex]._state = ItemStateChange.Paid;
    emit SupplyPaymentandDelivery(msg.sender,address(this), itemIndex, address(items[itemIndex]._item));
}

// Changes the state of the item from paid to delivered in the work flow.
function deliverItem(uint itemIndex) public onlyOwner{
    require(items[itemIndex]._state == ItemStateChange.Paid, "We have an issue processing this request, please ensure your item has been paid for");
    items[itemIndex]._state = ItemStateChange.Delivered;
    emit SupplyPaymentandDelivery(msg.sender,address(this), itemIndex, address(items[itemIndex]._item));
}
// Allows the owner to withdraw a specified amount from this smart contract that is equal to or less than the balance
function withdrawFunds(address payable _to, uint _amount) public onlyOwner{
    require(_amount <= address(this).balance, "There are not enough funds available");
    _to.transfer(_amount);
}
}

