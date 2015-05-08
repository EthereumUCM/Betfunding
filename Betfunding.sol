contract Betfunding {
	
	struct BetfundingProject{
		uint numNiceGamblers;
		mapping(uint => address) niceGamblers;
		
		uint numBadGamblers;
		mapping(uint => address) badGamblers;
		
		mapping(address => uint) amountBets;
		
		address projectCreator;
		string32 projectName;
		string32 projectDescription; // TODO: There is no text type (string array (?))
		uint expirationDate;
		string32 verificationMethod;
		
		bool projectVerified;
		address verificationJudge;
	}
	
	/// List of projects
	mapping(uint => BetfundingProject) projectMapping;
	uint numProjects;
	
	function Betfunding() {
		numProjects = 0;
	}
	
	/// Creates a new project
	function createProject(string32 _projectName, string32 _projectDescription, uint _expirationDate, string32 _verificationMethod, address _judge){
		numProjects += 1;
		
		BetfundingProject newProject = projectMapping[numProjects];
		newProject.projectName = _projectName;
		newProject.projectCreator = msg.sender;
		newProject.projectDescription =_projectDescription;
		newProject.expirationDate = _expirationDate;
		newProject.verificationMethod = _verificationMethod;
		newProject.verificationJudge = _judge;
	}
	
	/** Projects functions **/
	
	function bid(uint projectID, bool isNiceBet){
		BetfundingProject project =	projectMapping[projectID];
		
		/// Checks that the user has not bet before from the same address
		/// COMMENTED FOR TESTING PURPOSES
		///if(project.amountBets[msg.sender] == 0){		
			if(isNiceBet){
				project.numNiceGamblers += 1; 
				project.niceGamblers[project.numNiceGamblers] = msg.sender;
				project.amountBets[msg.sender] = msg.value;
			}
			else{
				project.numBadGamblers += 1;
				project.badGamblers[project.numBadGamblers] = msg.sender;
				project.amountBets[msg.sender] = msg.value;
			}
		///}
	}
	
	function checkExpirationDate(uint projectID) returns (bool hasExpired){
		BetfundingProject project =	projectMapping[projectID];
		
		if(block.timestamp < project.expirationDate/1000)
			return true;
		else 
			return false;
	}
	
	function checkProjectEnd(uint projectID){
		BetfundingProject project =	projectMapping[projectID];
		
		if(checkExpirationDate(projectID) && getNiceBets(projectID) > 0 && project.projectVerified){
			/// The project has been done
			var niceAmount = getNiceBets(projectID);
			var badAmount = getBadBets(uint projectID);
			var totalAmount = niceAmount + badAmount;
						
			uint numBets = 1;
			uint sum = (project.numNiceGamblers * (project.numNiceGamblers + 1)) / 2;
			while(numBets <= project.numNiceGamblers){
				address a = project.niceGamblers[numBets];
				uint amountBet = project.amountBets[project.niceGamblers[numBets]];
				
				/// There are no decimals, that's why we have to multiply it and then divide it by 1000
				/// Weighed by order and amount
				uint aux = amountBet + (((1000*(project.numNiceGamblers-(numBets-1))/sum + 1000*amountBet/niceAmount)/2)*badAmount)/1000;
				
				a.send(aux);
			}
		}
		else{
			/// The project has not been done
			var niceAmount = getNiceBets(projectID);
			var badAmount = getBadBets(uint projectID);
			var totalAmount = niceAmount + badAmount;
						
			uint numBets = 1;
			while(numBets <= project.numBadGamblers){
				address a = project.badGamblers[numBets];
            	uint amountBet = project.amountBets[project.badGamblers[numBets]];
				
				/// There are no decimals, that's why we have to multiply it and then divide it by 1000
				/// Weighed by amount
				uint aux = (((amountBet*1000) / badAmount)) * totalAmount) / 1000;
				
				a.send(aux);
			}
		}
	}
	
	function verifyProject(uint projectID){
		BetfundingProject project =	projectMapping[projectID];
		
		if(msg.sender == project.verificationJudge){
			if(checkExpirationDate(projectID))
				project.projectVerified = true;
			else
				project.projectVerified = false;
		}
	}
	
	/** Getters */
	
	function getNiceBets(uint projectID) returns (uint amount){
		BetfundingProject project =	projectMapping[projectID];
		uint numBets = 1;
		amount = 0;
		
		while(numBets <= project.numNiceGamblers){
			amount +=  project.amountBets[project.niceGamblers[numBets]];
			numBets++;
		}
		
		return amount;
	}
	
	function getNumNiceBets(uint projectID) returns (uint num){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.numNiceGamblers;
	}
	
	function getBadBets(uint projectID) returns (uint amount){
		BetfundingProject project =	projectMapping[projectID];
		uint numBets = 1;
		amount = 0;
		
		while(numBets <= project.numBadGamblers){
			amount +=  project.amountBets[project.badGamblers[numBets]];
			numBets++;
		}
		
		return amount;
	}
	
	function getNumBadBets(uint projectID) returns (uint num){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.numBadGamblers;
	}
	
	function getNumProjects() constant returns (uint num){
		
		return numProjects;
	}
	
	function getProjectName(uint projectID) returns (string32 name){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectName;
	}
	
	function getProjectEndDate(uint projectID) returns (uint date){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.expirationDate;
	}
	
	function getProjectVerification(uint projectID) returns (string32 verificacion){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.verificationMethod;
	}
	
	function getProjectJudge(uint projectID) returns (address addr){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.verificationJudge;
	}
	
	function getProjectDescription(uint projectID) returns (string32 description){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectDescription;
	}
	
	function getProjectCreator(uint projectID) returns (address addr){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectCreator;
	}
}