pragma solidity ^0.4.0;
contract Eethiq {


uint public zakaahCoins;
uint public numDonors;
uint public numProjects; 
uint public numCharities; 
uint public numTransactions;
uint public numRequests;
uint public numapprovedRequests;

//needs to be provided by Human Crescent before deploying contract in public Ethereum blockchain
address owner;

//initializes the number of zakaah coins with Human Cresecent
event finish();
function Eethiq(){
    owner=msg.sender;
    zakaahCoins=1000000;    
    }
//update zakaah coins, can be done only by Human Crescent
function updateZakaahcoins(uint amount){
    if(msg.sender!=owner){
        throw;
    }
    zakaahCoins+=amount;
    }

//Creates structure for transactions
struct Transaction{
    address sender;
    uint receiverID;
    uint ID;
    uint amount;
    uint time;
    } 

mapping(uint=>Transaction)public transactions;
    
/////////////////////////////////////////////////////////////////
//Donor Functions 
/////////////////////////////////////////////////////////////////

// Data structure to hold information about donors
struct Donor {
    bytes32 name;
    address addr;
    uint donorID;
    uint amount;
    uint[] transactionID;
    }
//creates a mapping of donor datatypes
mapping(address=>Donor)balances;

// Register new donor
function newDonor(bytes32 name, address Doaddr){
    if(name==""){
        throw;
    }
    numDonors++;
    balances[Doaddr].addr=Doaddr;
    balances[Doaddr].donorID=numDonors;
    balances[Doaddr].name=name;   
    }
// Get Donor data 
function donorData()constant returns(string name, address addr, uint donorID, uint amount)
    {
    name=bytes32ToString(balances[msg.sender].name);
    return(name,balances[msg.sender].addr, balances[msg.sender].donorID, balances[msg.sender].amount);
    } 

function getDonor(address daddr) constant returns (bytes32 name, address addr, uint donorID, uint amount)
{
    name=balances[daddr].name;
    addr=balances[daddr].addr;
    donorID=balances[daddr].donorID;
    amount=balances[daddr].amount;
}    

// Get donor transactions
function donorTrans()constant returns(uint[] transactionID)
    {
        return balances[msg.sender].transactionID;
    }

// Buy Zakaah Coins
function buyCoins( uint amount){
    if(msg.sender!=balances[msg.sender].addr){
        throw;   }
    uint increaseCoin = amount;
    if(zakaahCoins<amount){
        throw;  }
    balances[msg.sender].amount += increaseCoin;
    zakaahCoins-=amount;
    numTransactions++;
    transactions[numTransactions].ID=numTransactions;
    transactions[numTransactions].sender=owner;
    transactions[numTransactions].receiverID=balances[msg.sender].donorID;

    transactions[numTransactions].ID=numTransactions;
    transactions[numTransactions].amount=amount;

    transactions[numTransactions].time=now;
    balances[msg.sender].transactionID.push(numTransactions);
    }

// Donation 
event Contribute(bool done);
function donate(uint projectID, uint amount)returns (bool success) {
    if (projects[projectID].amount >= projects[projectID].fundingGoal){
    Contribute(false);
    return false;
    }
    //only registered senders will be able to trigger the function
    if(msg.sender!=balances[msg.sender].addr){
        Contribute(false);
        return false;
    }
    if(balances[msg.sender].amount<amount){
        Contribute(false);
        return false;
    }
    uint remamount=projects[projectID].fundingGoal-projects[projectID].amount;
    if(remamount<amount){
        Contribute(false);
        return false;
    }
    Project p = projects[projectID];
    
    p.amount += amount;
    balances[msg.sender].amount-=amount;
    p.listDonors.push(balances[msg.sender].donorID);
        numTransactions++;
        Transaction t=transactions[numTransactions];
            t.sender=msg.sender;
            t.receiverID=projectID;
            t.ID=numTransactions;
            t.amount=amount;
            t.time=now;
            balances[msg.sender].transactionID.push(numTransactions);
            p.transactionList.push(numTransactions);
            Contribute(true);
            return true;
    }

// Get a project's donors
function donorsProjects(uint projectID)constant returns(uint[] listDonors){
    return projects[projectID].listDonors;
    }

/////////////////////////////////////////////////////////////////
// Charity functions
/////////////////////////////////////////////////////////////////
    
mapping(uint=>Charity)charities; // Mapping of charity datatypes
mapping (uint => Project)projects; //Creates a mapping of Project datatypes

//Data structure of charity
struct Charity{
    bytes32 name;
    address addr;
    uint amount;
    uint charityID;  
    uint requestCash;
    uint numberR; 
    uint[] listProjects;
    uint[] requests;
    }

//creates a new charity
function newCharity(bytes32 name){
        if(name==""){
        throw;    }
    numCharities++;
    uint charityID=numCharities;
    Charity c=charities[charityID];
    c.name=name;
    c.addr=msg.sender;
    c.charityID=charityID;
    
    }

// Project data structure
struct  Project{
    address addr;
    bytes32 name;
    uint charityID;
    uint fundingGoal;
    uint amount;
    uint cash;
    bytes32 category;
    bytes32 impact;
    uint projectID;
    uint[] listDonors;
    uint[] transactionList;
    }

//6  Project categories lists the projects in each category get se return function this is not working as intended
uint[]  category1;
uint[]  category2;
uint[]  category3;
uint[]  category4;
uint[]  category5;
uint[]  category6;
  
//Regisiter a new project
function newProject(bytes32 name, uint charityID, uint goal, uint categoryID) {
    numProjects++; 
    uint projectID=numProjects;
    Project p = projects[projectID]; // assigns reference
    p.charityID = charityID;
    charities[charityID].listProjects.push(projectID);
    p.fundingGoal = goal;
    p.cash=0;
    p.addr=msg.sender;
    p.name=name;
    p.projectID=numProjects;
    
        if(categoryID==1){
                p.category="Trafficking Victims";
                category1.push(projectID);
            }
        else if(categoryID==2){
                p.category="Refugees/IDPs";
                category2.push(projectID);
            }
        else if(categoryID==3){
                p.category="Microfinance Clients";
            category3.push(projectID);
            }
        else if(categoryID==4){
            p.category ="Education";
                category4.push(projectID);
            }
        else if(categoryID==5){
                p.category ="Disaster Victims";
                category5.push(projectID);
            }
        else{
                p.category ="Poverty Alleviation";
                category6.push(projectID);
        }
            
    p.impact="To be estimated";
    
    }

// Get a project data
function projectData(uint projectID)constant returns(string name,  uint charityID,uint fundingGoal,uint amount,uint cash,address addr,string category,string impact, uint pID){
    category=bytes32ToString(projects[projectID].category);
    impact=bytes32ToString(projects[projectID].impact);
    name=bytes32ToString(projects[projectID].name);
    charityID=projects[projectID].charityID;
    fundingGoal=projects[projectID].fundingGoal;
    
    amount=projects[projectID].amount;
    cash=projects[projectID].cash;
    addr=projects[projectID].addr;
    pID=projects[projectID].projectID;
    return(name,charityID,fundingGoal,amount,cash,addr,category,impact,pID);
    }

// Get a projects' transactions
function transProjects(uint projectID)constant returns(uint[] transactionList){
    return projects[projectID].transactionList;
    }

//Give a project's impact
function impact(uint projectID, bytes32 impact) {
    if(msg.sender!=projects[projectID].addr){
        throw;  }
    projects[projectID].impact=impact;
    }

// Get Category
function getCategory(uint categoryID)constant returns(uint[] category){
    if(categoryID==1){
        return category1;
    }
    else if(categoryID==2){
        return category2;
    }
    else if(categoryID==3){
        return category3;
    }
    else if(categoryID==4){
        return category4;
        
    }
    else if(categoryID==5){
        return category5;
    }
    else
    return category6;
    }



/////////////////////////////////////////////////////////////////
// Human Crescen functions
/////////////////////////////////////////////////////////////////

//exchange coins into cash from Human Crescent. Use payment gateway to send cash.After yes from them trigger this function
function exchangeCoins(uint requestID){
    if(msg.sender!=owner){ 
        throw; }
    if(!approves[requestID].clear){
        throw; }

    uint projectID;
    projectID=requests[requestID].projectID;
    projects[projectID].cash=projects[projectID].amount;
    zakaahCoins+=projects[projectID].amount;
    projects[projectID].amount=0;       
    requests[requestID].requestID=0;//removes request from the queue with all other data remaining
    }

//concerned charity will check for approval if project has delivered impact
struct Approve{
    uint ApproveID;
    uint requestID;
    bool clear;   
    }
mapping(uint=>Approve) public approves;

// Approve a project 
function giveApproval(uint requestID,bool clear) {
    //Create new Approve object
    if(clear==true){
    numapprovedRequests++;
    uint ApproveID=numapprovedRequests;
    approves[ApproveID].ApproveID=ApproveID;
    approves[ApproveID].requestID=requestID;
    approves[ApproveID].clear=clear;

    }

    }

// Get approved projects     
function getApproved()constant returns(uint[] approveRequests){
    return approveRequests;
    }
// Request for Cash data strucure 
struct Request{
    uint requestID;
    uint projectID;
    uint requestCash;
    uint charityID;
    }
   
mapping(uint=>Request)requests;

// Send a Requst for cash   
function requestCash(uint projectID){
    if(projects[projectID].amount!=projects[projectID].fundingGoal){
        throw;
    }
    numRequests++;
    requests[numRequests].requestID=numRequests;
    charities[projects[projectID].charityID].numberR++;
    requests[numRequests].requestCash=projects[projectID].amount;
    requests[numRequests].charityID=projects[projectID].charityID;
    requests[numRequests].projectID=projectID;
    charities[projects[projectID].charityID].requests.push(numRequests);
    }

   // Get Charity data
    function charityData(uint charityID)constant returns(string name, address addr, uint ID){
        Charity x=charities[charityID];
        name=bytes32ToString(x.name);
        addr=x.addr;
        ID=x.charityID;
        return (name,addr,ID);
    }

//Get Charitys' projects
function charityProjects(uint charityID)constant returns(uint[] listProjects){
    return charities[charityID].listProjects;
    }

// Get Charity Requests
function charityRequests(uint charityID)constant returns(uint[] requests){
    return charities[charityID].requests;
    } 

//Get Request data
function Requestdata(uint requestID) constant returns(uint id, uint projectid, uint requstcash, uint charityid){ 
    id=requests[requestID].requestID;
    projectid=requests[requestID].projectID;
    requstcash=requests[requestID].requestCash;
    charityid=requests[requestID].charityID;
    return(id,projectid,requstcash,charityid);
    }

//Get Impact
function getImpact(uint projectID)constant returns(string impact){
    impact=bytes32ToString(projects[projectID].impact);
    return impact;
    }
/////////////////////////////////////////////////////////////////    
// Support functions
/////////////////////////////////////////////////////////////////         
//converts bytes32 to string
function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
    }




//kill the contract
//function kill() {
  //      if (msg.sender != owner){
    //        throw;
      //  } 
        //selfdestruct(owner);
    //}
/////////////////////////////////////////////////////////////////    
  
}// end of contract

