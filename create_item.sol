pragma solidity ^0.7.4;

contract SupplyChain {

enum ItemStateChange {Created,Paid,Delivered}

// Struct used in combination with a variable for the uint to make a mapping
struct S_Item {
    string _identifier;
    uint _itemPrice;
    SupplyChain.ItemStateChange _state;
}

// Mapping used to couple each itemIndex with it's respective struct
mapping(uint => S_Item) public item;

uint itemIndex;

event SupplyChainStep(address indexed _from, address _to, string _identifier, uint _itemPrice);

event SupplyPaymentandDelivery(address indexed _from, address _to, uint indexed itemIndex);

// Creates the the item leveraging the S_Item struct defined earlier
function createOrder(string memory _identifier, uint _itemPrice) public{
    item[itemIndex]._identifier = _identifier;
    item[itemIndex]._itemPrice = _itemPrice;
    item[itemIndex]._state = ItemStateChange.Created;
    itemIndex++;
    emit SupplyChainStep(msg.sender,address(this), _identifier, _itemPrice);
}

// Ensures that only an item that has been created can be paid for as well as updates the state to paid after the transaction
function payforItem(uint itemIndex) public payable {
    require(item[itemIndex]._state == ItemStateChange.Created, "We have an issue processing this request, your item might be further in the chain");
    require(item[itemIndex]._itemPrice == msg.value, "Only full payments are accepted!");
    item[itemIndex]._state = ItemStateChange.Paid;
    emit SupplyPaymentandDelivery(msg.sender,address(this), itemIndex);
}

// Changes the state of the item from paid to delivered in the work flow.
function deliverItem(uint _itemIndex) public {
    require(item[_itemIndex]._state == ItemStateChange.Paid, "We have an issue processing this request, please ensure your item has been paid for");
    item[_itemIndex]._state = ItemStateChange.Delivered;
    emit SupplyPaymentandDelivery(msg.sender,address(this), _itemIndex);
}

}

