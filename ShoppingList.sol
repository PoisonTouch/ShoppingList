pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import 'Additional.sol';

contract ShoppingList {
   
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    mapping (uint32=>purchase) purchaseMapping;
    uint256 m_ownerPubkey;
    uint32 purchaseId;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function getShoppingSummary() public view returns (summaryPurchases summary){
        uint amountOfPaid;
        uint amountOfUnpaid;
        uint allPaidPrice;
        for ((, purchase purchase) : purchaseMapping){
            if (purchase.status == true) {
                amountOfPaid++;
                allPaidPrice += purchase.price;
            } else{
                amountOfUnpaid++;
            }
        }
        summary = summaryPurchases(amountOfPaid, amountOfUnpaid, allPaidPrice);
    }

    function getShoppingList() public view returns (purchase[] purchasesArr){
        tvm.accept();
        for (uint32 i; i <= purchaseId; i++){
            purchasesArr.push(purchaseMapping[i]);
        }
    }

    function addPurchase(string name, uint32 number) public onlyOwner {
        tvm.accept();
        purchaseId++;
        purchaseMapping[purchaseId] = purchase(purchaseId, name, number, now, false, 0);
    }

    function deletePurchase(uint32 purchaseID) public onlyOwner {
        tvm.accept();
        require(purchaseMapping.exists(purchaseID), 102);
        delete purchaseMapping[purchaseID];
    }

    function buy(uint32 purchaseID, uint32 priceForAll) public onlyOwner{
        tvm.accept();
        require(purchaseMapping.exists(purchaseID), 102);
        purchaseMapping[purchaseID].status = true;
        purchaseMapping[purchaseID].price = priceForAll;
    }
}