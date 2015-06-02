/* Test data */
var mainContractAddress = '0x' + '5109d44fc187da44fc339a9dd68dcf9099167b2c';

var abiMainContract = [{"constant":true,"inputs":[],"name":"getNumProjects","outputs":[{"name":"num","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectCreator","outputs":[{"name":"addr","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getNiceBets","outputs":[{"name":"amount","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectEndDate","outputs":[{"name":"date","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getNumNiceBets","outputs":[{"name":"num","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectVerified","outputs":[{"name":"val","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"checkProjectEnd","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectDescription","outputs":[{"name":"description","type":"string32"}],"type":"function"},{"constant":false,"inputs":[{"name":"_projectName","type":"string32"},{"name":"_projectDescription","type":"string32"},{"name":"_expirationDate","type":"uint256"},{"name":"_judge","type":"address"}],"name":"createProject","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getBadBets","outputs":[{"name":"amount","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"},{"name":"isNiceBet","type":"bool"}],"name":"bid","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectJudge","outputs":[{"name":"addr","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"checkExpirationDate","outputs":[{"name":"hasExpired","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getNumBadBets","outputs":[{"name":"num","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"verifyProject","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"projectID","type":"uint256"}],"name":"getProjectName","outputs":[{"name":"name","type":"string32"}],"type":"function"}];

var mainContract = web3.eth.contractFromAbi(abiMainContract); // Old version
// var MyContract = web3.eth.contract(abi); // New versions

var mainContractInstance = new mainContract(mainContractAddress);

// List of projects
postProjectsTable();

/* Main contract */

// Send the information to the blockchain to create a contract
function createProject() {
	var pname = document.getElementById("pname").value;	
	var pjudge = document.getElementById("pjudge").value;
	var pdescription = document.getElementById("pdescription").value;
	var numDays = parseInt(document.getElementById("pdate").value);
	
	var pdate = Date.now() + (numDays*24*60*60*1000); // timestamp
	
	mainContractInstance.createProject(pname, pdescription, pdate, pjudge);
}

// Put a bet into the blockchain
function bet(isNiceBet) {
	var pid = parseInt(document.getElementById("projectId").innerHTML);	
	var amount = parseInt(document.getElementById("betAmount").value);	
	
	mainContractInstance.transact({value: amount}).bid(pid, isNiceBet);
	// mainContractInstance.sendTransaction({value: amount}).bid(pid, isNiceBet); // New versions
}


/* Getters */

function getNumProjects() {
	var res = parseInt(mainContractInstance.call().getNumProjects());
	
	return res;
}

function getProjectName(id) {	
	var res = mainContractInstance.call().getProjectName(id);
	
	return res;
}

function getProjectCreator(id) {	
	var res = mainContractInstance.call().getProjectCreator(id);
	
	return res;
}

// Return the timestamp
function getProjectEndDate(id) {	
	var res = parseInt(mainContractInstance.call().getProjectEndDate(id));
	
	return res;
}

function getNumNiceBets(id) {	
	var res = parseInt(mainContractInstance.call().getNumNiceBets(id));
	
	return res;
}

function getNumBadBets(id) {	
	var res = parseInt(mainContractInstance.call().getNumBadBets(id));
	
	return res;
}

function getProjectJudge(id) {	
	var res = mainContractInstance.call().getProjectJudge(id);
	
	return res;
}

function getProjectDescription(id) {	
	var res = mainContractInstance.call().getProjectDescription(id);
	
	return res;
}

function getNiceBetsAmount(id) {	
	var res = parseInt(mainContractInstance.call().getNiceBets(id));
	
	return res;
}

function getBadBetsAmount(id) {	
	var res = parseInt(mainContractInstance.call().getBadBets(id));
	
	return res;
}

// Return a list of bets
function getProjectListBets1(id) {	
	// TODO (?)
}

function getProjectListBets2(id) {	
	// TODO (?)
}

// TODO: List of bets  (?)
function getProject(id) {

	var project = {
		id: id,
		name: getProjectName(id),
		creator: getProjectCreator(id),
		endDate: getProjectEndDate(id),
		numNiceBets: getNumNiceBets(id),
		numBadBets: getNumBadBets(id),
		niceBetsAmount: getNiceBetsAmount(id),
		badBetsAmount: getBadBetsAmount(id),
		judge: getProjectJudge(id),
		description: getProjectDescription(id)
	};
	
	return project;
}

/* View */

function postProject(id) {
	var ok;
	var numProjects = getNumProjects();
	
	if(id <= numProjects && id > 0){
		var project = getProject(id);
		
		document.getElementById("projectId").innerText = project["id"];
		document.getElementById("projectName").innerText = project["name"];
		document.getElementById("projectCreator").innerText = project["creator"];
		
		var d = new Date(project["endDate"]);
		document.getElementById("projectEndDate").innerText =  [(d.getMonth()+1), d.getDate(), d.getFullYear()].join('/') + ' ' + [d.getHours(), d.getMinutes(), d.getSeconds()].join(':');
		
		document.getElementById("projectNiceBets").innerText = project["niceBetsAmount"] + ' (' + project["numNiceBets"] + ' bets)';
		document.getElementById("projectBadBets").innerText = project["badBetsAmount"] + ' (' + project["numBadBets"] + ' bets)';
		
		document.getElementById("projectJudge").innerText = project["judge"];
		document.getElementById("projectDescription").innerText = project["description"];
		
		document.getElementById("project-info").style.display = "block";
		
		// Check if the user if the judge of the project
		var accounts = web3.eth.accounts;
		for(var i = 0; i < accounts.length; i++){
			if(project["judge"] == accounts[i])
				document.getElementById("verificationButton").style.display = "inline";
		}
		
		var timestamp = Date.now();
		var verified = mainContractInstance.call().getProjectVerified(id);
		if(timestamp > project["endDate"] || verified){
			document.getElementById("open").className = "label label-danger right";
			document.getElementById("open").innerText = "Closed";
			
			document.getElementById("betAmount").innerHTML = "This project is closed.";
			document.getElementById("betAmount").disabled = true;
			document.getElementById("niceBetButton").disabled = true;
			document.getElementById("badBetButton").disabled = true;
			
			document.getElementById("verificationButton").style.display = "none";
		}else{
			document.getElementById("open").className = "label label-success right";
			document.getElementById("open").innerText = "Open";
		}
		
		ok = true;
	}else{
		ok = false;
	}
	
	return ok;
}

function postProjectsTable() {
	var numProjects = getNumProjects();	
	var tbody = document.getElementById("projectsTable").tBodies[0];
	
	for(var i = 1; i <= numProjects; i++){
		var row = tbody.insertRow(0);
		
		var cell1 = row.insertCell(0); // id
		var cell2 = row.insertCell(1); // name
		var cell3 = row.insertCell(2); // end date
		var cell4 = row.insertCell(3); // niceBets
		var cell5 = row.insertCell(4); // badBets
		
		cell1.innerHTML = i;
		cell2.innerHTML = '<a href="#" onclick="return postProject(' + i + ')">' + getProjectName(i) + '<a>';
		var d = new Date(getProjectEndDate(i));
		cell3.innerHTML = [(d.getMonth()+1), d.getDate(), d.getFullYear()].join('/') + ' ' + [d.getHours(), d.getMinutes(), d.getSeconds()].join(':');
		cell4.innerHTML = getNiceBetsAmount(i) + ' (' + getNumNiceBets(i) + ' bets)';
		cell5.innerHTML = getBadBetsAmount(i) + ' (' + getNumBadBets(i) + ' bets)';
		
	}
}

function searchProject() {
	var id = document.getElementById("search-value").value;
	
	if(!postProject(id)){
		alert("There is no project with id " + id); // error message
	}
}

function verify(){
	var id = parseInt(document.getElementById("projectId").innerHTML);
	var address = getProjectJudge(id);
	if(confirm("Are you sure?"))
		mainContractInstance.transact({from: address}).verifyProject(id);
}

/* Test */

function checkExpirationDate(id) {
	
	var res = mainContractInstance.call().checkExpirationDate2(id);
	
	return res;
}











