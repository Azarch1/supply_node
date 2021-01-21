pragma solidity ^0.7.4;

contract SupplyChain {

enum ItemStateChange {Created,Paid,Delivered}

struct S_Item {
    string _identifier;
    uint _itemPrice;
    SupplyChain.ItemStateChange _state;
}

mapping(uint => S_Item) public item;

uint itemIndex;

event SupplyChainStep(address indexed _from, address _to, string _identifier, uint _itemPrice);

event SupplyPaymentandDelivery(address indexed _from, address _to, uint indexed itemIndex);

function createOrder(string memory _identifier, uint _itemPrice) public{
    item[itemIndex]._identifier = _identifier;
    item[itemIndex]._itemPrice = _itemPrice;
    item[itemIndex]._state = ItemStateChange.Created;
    itemIndex++;
    emit SupplyChainStep(msg.sender,address(this), _identifier, _itemPrice);
}

function payforItem(uint _itemIndex, uint _payment) public payable {
    require(item[_itemIndex]._state == ItemStateChange.Created, "We have an issue processing this request, your item might be further in the chain");
    require(item[_itemIndex]._itemPrice == _payment, "Only full payments are accepted!");
    item[itemIndex]._state = ItemStateChange.Paid;
    emit SupplyPaymentandDelivery(msg.sender,address(this), _itemIndex);
}

function deliverItem(uint _itemIndex) public {
    require(item[_itemIndex]._state == ItemStateChange.Paid, "We have an issue processing this request, please ensure your item has been paid for");
    item[_itemIndex]._state = ItemStateChange.Delivered;
    emit SupplyPaymentandDelivery(msg.sender,address(this), _itemIndex);
}

}

