//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// Switch this to your own contract address once deployed, for bookkeeping!
// Contract Address on Goerli: 0x493d2A16064EAf81Fb16Bbaa5e89d9960E61A98e

contract BuyMeACoffee {
    // Event to emit when a Memo is created.
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Memo struct.
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address payable withdrawAddress;

    // List of all memos received from coffee purchases.
    Memo[] memos;

    address private owner;

    constructor() {
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        withdrawAddress = payable(msg.sender);
        owner = msg.sender;

    }

    modifier requireOwner(){
        require(owner == msg.sender, "Callable by owner only");
        _;
    }

    /**
     * @dev fetches all stored memos
     */
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
        *@dev updates withdrawal address- only owner can
    
      */
      function updateWithdrawalAddress(address _address) public requireOwner {
          withdrawAddress = payable(_address);
      }
    /**
     * @dev buy a coffee for owner (sends an ETH tip and leaves a memo)
     * @param _name name of the coffee purchaser
     * @param _message a nice message from the purchaser
     */
    function buyCoffee(string memory _name, string memory _message) public payable {
        // Must accept more than 0 ETH for a coffee.
        require(msg.value > 0, "can't buy coffee for free!");

        // Add the memo to storage!
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewMemo event with details about the memo.
        emit NewMemo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    function withdrawTips() public {
        require(withdrawAddress.send(address(this).balance));
    }
}