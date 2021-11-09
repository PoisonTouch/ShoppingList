pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "base/Debot.sol";
import "base/Terminal.sol";
import "base/Menu.sol";
import "base/AddressInput.sol";
import "base/ConfirmInput.sol";
import "base/Upgradable.sol";
import "base/Sdk.sol";
import "Additional.sol";
import "ShoppingList.sol";
import "AInitListDebot.sol";

contract FillShoppingListDebot is AInitListDebot  {
    string purchaseName;
    function setStat(summaryPurchases stat) public override {
        m_stat = stat;
        _menu();
    }

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {} paid purchaces,{} unpaid purchaces. Total price of paid purchases is {}", m_stat.amountOfPaid,m_stat.amountOfUnpaid,m_stat.allPaidPrice),
            sep,
            [
                MenuItem("Add new purchase","",tvm.functionId(addPurchaseToReadName)),
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }

    function addPurchaseToReadName(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addPurchaseToReadNumber), "Enter purchase name:", false);
    }

    function addPurchaseToReadNumber(string name) public {
        purchaseName = name;
        Terminal.input(tvm.functionId(addPurchase_), "Enter amount of purchase:", false);
    }

    function getShoppingList(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShoppingList(m_address).getPurchasesSummary{
            abiVer: 2,
            sign: false,
            pubkey: none,
            extMsg: true,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getShoppingList_),
            onErrorId: 0
        }();
    }

    function addPurchase_(string number) public view {
        (uint256 num,) = stoi(number);
        uint32 numOfItems = uint32(num);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).createPurchase{
                abiVer: 2,
                sign: true,
                pubkey: pubkey,
                extMsg: true,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(purchaseName, numOfItems);
    }

    

    function getShoppingList_(purchase[] purchasesArr) public {
        uint32 i;
        if (purchasesArr.length > 0 ) {
            Terminal.print(0, "Your shopping list is:");
            for (i = 0; i < purchasesArr.length; i++) {
                purchase Purchase = purchasesArr[i];
                string statusOfBuy;
                if (Purchase.status) {
                    statusOfBuy = '✓';
                } else {
                    statusOfBuy = ' ';
                }
                Terminal.print(0, format("{} {}  {} {}  at {}", Purchase.id, statusOfBuy, Purchase.amount, Purchase.name, Purchase.creationDate));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        index = index;
        if (m_stat.amountOfPaid + m_stat.amountOfUnpaid > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you haven't purchases to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).deletePurchase{
                abiVer: 2,
                sign: true,
                extMsg: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
}