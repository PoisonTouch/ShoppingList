pragma ton-solidity >=0.35.0;

struct purchase{
    uint id;
    string name;
    uint amount;
    uint creationDate;
    bool status;
    uint price;
}

struct summaryPurchases{
    uint amountOfPaid;
    uint amountOfUnpaid;
    uint allPaidPrice;
}

interface ITransactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}
    
interface IShoppingList {
    function createPurchase(string name,uint amount) external;  
    function deletePurchase(uint id) external;
    function buyPurchase(uint id, uint price) external;
    function getAllPurchases() external returns (purchase[] purchases);
    function getPurchasesSummary() external returns (summaryPurchases summarypurchases);
}

abstract contract AHasConstructorWithPubKey {
   constructor(uint256 pubkey) public {}
}
