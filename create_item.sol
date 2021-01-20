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

function createOrder(string memory _identifier, uint _itemPrice) public{
    item[itemIndex]._identifier = _identifier;
    item[itemIndex]._itemPrice = _itemPrice;
    item[itemIndex]._state = ItemStateChange.Created;
    itemIndex++;
}

function payforItem(uint _itemIndex) public payable {
    require(item[itemIndex]._itemPrice == msg.value, "Only full payments are accepted!");
    require(item[itemIndex]._state == ItemStateChange.Created, "We have an issue processing this request, your item might be further in the chain");
    item[itemIndex]._state = ItemStateChange.Paid;
}

function deliverItem(uint _itemIndex) public {
    require(item[itemIndex]._state == ItemStateChange.Paid, "We have an issue processing this request, please ensure your item has been paid for");
    item[itemIndex]._state = ItemStateChange.Delivered;
}

}

