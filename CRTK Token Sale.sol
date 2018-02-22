pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
    function transferAll(address _to) public;
}

contract TokenSale {
    address public owner;
    uint public startTime;             
    uint public totalNumOfInvestors = 0;
    token public tokenReward;
    mapping(uint => address) public investors;
    event TokenTransfer(address indexed investor, uint amountOfTokens);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokensReturned(address indexed to);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function TokenSale (
        uint startTimeAsTimestamp,
        address addressOfTokenUsedAsReward
    ) public {
        require(startTimeAsTimestamp >= now);

        owner = msg.sender;
        tokenReward = token(addressOfTokenUsedAsReward);
        startTime = startTimeAsTimestamp;
    }

    /**
     * Function which sends tokens to a given address. 
     * 
     */
    function issueTokens(address to, uint tokenQuantity) onlyOwner public {
        require (to != address(0));
        require (tokenQuantity > 0);

        tokenReward.transfer(to, tokenQuantity*10**uint(6));

        if (!investorExists(to)) {

            // add investor to 'investors' mapping
            investors[totalNumOfInvestors] = to;
            totalNumOfInvestors++;
        }       

        // *** EVENT *** //
        TokenTransfer(to, tokenQuantity);
        // *** EVENT *** //
    }
    
    /**
     * Helper that checks whether an investor exists in the investors mapping.
     */
    function investorExists(address investorAddress) private view returns (bool) {
        for (uint i = 0; i < totalNumOfInvestors; i++) {
            if (investors[i] == investorAddress) {
                return true;
            }
        }
        return false;
    }

    /**
     * Transfers all of the remaining tokens from the TokenSale contract to the defined owner.
     */
    function returnTokensToOwner() onlyOwner public {
        tokenReward.transferAll(owner);

        // *** EVENT *** //
        TokensReturned(owner);
        // *** EVENT *** //
    }

    /**
     * Adds the option to define a new owner.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));

        // *** EVENT *** //
        OwnershipTransferred(owner, newOwner);
        // *** EVENT *** //

        owner = newOwner;
    }

    /**
     * Destroys the contract and releases all of the funds. 
     * note: In our specific case no funds will be released
     * because our TokenSale contract doesn't have a payable 
     * function and thus cannot receive ether.
     */
    function killContract() onlyOwner public {
        selfdestruct(owner);
    }

     /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
