pragma solidity ^0.7.4;

contract SupplyChain {

enum ItemStateChange {Created,Paid,Delivered}

struct S_Item {
    string _identifier;
    uint _itemPrice;
    SupplyChain.ItemStateChange _state;
}

mapping(uint => S_Item) item;

uint itemIndex;

function createOrder(string memory _identifier, uint _itemPrice) public{
    item[itemIndex]._identifier = _identifier;
    item[itemIndex]._itemPrice = _itemPrice;
    item[itemIndex]._state = ItemStateChange.Created;
    itemIndex++;
}

function payforItem() public {

}

function deliverItem() public {

}

}

