pragma solidity ^0.4.0;
contract BetfungingProject {
    
    address public creator;
    uint public deadline; // timestamp
    address oracle;
    bool verified;
    Bets bets;
    
    string name; // to IPFS
    string desc; // to IPFS
    // TODO: Add IPFS hash
            
    // To claim the profits
    mapping(address => uint) public balances;
    
    struct Bets{
        uint numSuccessGamblers;
        uint successBounty;
        mapping(uint => address) orderSuccessGamblers;
        
        uint numFailGamblers;
        uint failBounty;
        mapping(uint => address) orderFailGamblers;
        
        mapping(address => uint) amount;
        uint distributionIndex;
    }
    
    function BetfungingProject(string _name, string _desc, uint _deadline, address _oracle){
        name = _name;
        desc = _desc;
        deadline = _deadline;
        oracle = _oracle;
    }
    
    event Bet(address indexed gambler, uint amount, bool success);
    event Result(address indexed oracle, bool result);
    event Distribution();
    
    modifier isFirstBet() {
        if (bets.amount[msg.sender] > 0 )
            throw;
        _;
    }
    
    modifier sendsEther() {
        if (msg.value == 0 )
            throw;
        _;
    }
    
    modifier onlyOracle() {
        if (oracle != msg.sender)
            throw;
        _;
    }
    
    modifier bettingTime() {
        if (now > deadline)
            throw;
        _;
    }
    
    modifier verificationTime() {
        if (now < deadline || 
            now > deadline + 7 days)
            throw;
        _;
    }
    
    modifier closed(uint projectId) {
        if (now < deadline + 7 days)
            throw;
        _;
    }
    
        function bet(uint projectId, bool success)
        payable
        isFirstBet()
       // projectInRange(projectId)
        sendsEther
        bettingTime()
    {
        if(success){
            bets.orderSuccessGamblers[bets.numSuccessGamblers] = msg.sender;
            bets.successBounty += msg.value;
            bets.numSuccessGamblers++;
        }else{
            bets.orderFailGamblers[bets.numFailGamblers] = msg.sender;
            bets.failBounty += msg.value;
            bets.numFailGamblers++;
        }
        
        bets.amount[msg.sender] += msg.value;
        
        Bet(msg.sender, msg.value, success);
    }


    
    function verify(uint projectId, bool success)
        //projectInRange(projectId)
        verificationTime()
        onlyOracle()
    {
        verified = success;
    }
    
    function updateBalances(uint projectId)
        //projectInRange(projectId)
        closed(projectId)
    {
        uint txLimit;
        address user;
        uint amountBet;
        uint bounty = bets.successBounty + bets.failBounty;
        
        if(verified){
            // To avoid tx gas limit
            txLimit = bets.distributionIndex + 100;
            if(txLimit > bets.numSuccessGamblers){
                txLimit = bets.numSuccessGamblers;
                
                Distribution(); // last iteration
            }
            
            // Distribution
            while(bets.distributionIndex < txLimit){
                user = bets.orderSuccessGamblers[bets.distributionIndex];
                amountBet = bets.amount[user];
                
                // The user receives his share of the bounty
                // Sumatory (used to weight by order):
                uint sum = (bets.numSuccessGamblers * (bets.numSuccessGamblers + 1)) / 2;
                //  Percent of bounty received by the user weighed by order of bets:
                uint shareOrder = 10000*(bets.numSuccessGamblers-bets.distributionIndex)/sum;
                // Percent of the bounty received by the user weighed by amount bet:
                uint shareAmount = 10000*amountBet/bets.successBounty;
                // Mean of the previous percents:
                uint share = ((shareOrder+shareAmount)/2);
                // Finally, the user gets back his bet + his share of the failBounty:
                balances[user] += amountBet + (share*bets.failBounty)/10000;
                
                bets.distributionIndex++;
            }
        }else{
            // To avoid tx gas limit
            txLimit = bets.distributionIndex + 100;
            if(txLimit > bets.numFailGamblers){
                txLimit = bets.numFailGamblers;
                
                Distribution(); // last iteration
            }
            
            // Distribution
            while(bets.distributionIndex < txLimit){
                user = bets.orderFailGamblers[bets.distributionIndex];
                amountBet = bets.amount[user];
                
                // The user receives his share of the bounty
                balances[user] += ((amountBet*bounty*10000)/bets.failBounty)/10000;
                
                bets.distributionIndex++;
            }
        }
    }
    
    function claimProfits(){
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        
        if(!msg.sender.send(amount))
            throw;
    }
    
    function getBets() constant //projectInRange(i)
        returns(
            uint numSuccessGamblers,
            uint successBounty,
            uint numFailGamblers,
            uint failBounty
        )
    {
        numSuccessGamblers = bets.numSuccessGamblers;
        successBounty = bets.successBounty;
        
        numFailGamblers = bets.numFailGamblers;
        failBounty = bets.failBounty;
    }
}

contract Betfunding {


    // List of projects
    uint public numProjects;
    mapping(uint => BetfungingProject) projects;
    
    // Events
    event NewProject(uint indexed projectId, address creator);
    
    /*
     * Functions
     */
    
    // TODO: Change attributes name and description for IPFS hash
    function createProject(string name, string desc, uint deadline, address oracle){
        BetfungingProject newProject = new BetfungingProject(name,desc,deadline,oracle);
        projects[numProjects] = newProject;
        
        NewProject(numProjects, msg.sender);
        numProjects++;
    }

    

    
    /*
     * Getters
     */
    
    function getProject(uint i) constant //projectInRange(i)
        returns(
            address BetfungingProject
        )
    {
        return projects[i];
    }


}
