contract Betfunding {
	
	function Betfunding() {
		numProjects = 0;
	}
	
	/// Creates a new project
	function createProject(string32 _projectName, string32 _projectDescription, uint256 _expirationDate, string32 _verificationMethod, address _judge){
		numProjects += 1;
		
		BetfundingProject newProject = projectMapping[numProjects];
		newProject.projectName = _projectName;
		newProject.projectCreator = msg.sender;
		newProject.projectDescription =_projectDescription;
		newProject.expirationDate = _expirationDate;
		newProject.verificationMethod = _verificationMethod;
		newProject.verificationJudge = _judge;
	}
	
	/// List of projects
	mapping(uint256 => BetfundingProject) projectMapping;
	uint256 numProjects;
	
	/** Projects functions **/
	
	function bid(uint256 projectID, bool isNiceBet){
		BetfundingProject project =	projectMapping[projectID];
		
		/// Checks that the user has not bet before from the same address
		if(project.amountBets[msg.sender] == 0){		
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
		}
	}
	
	function checkExpirationDate(uint256 projectID) returns (bool hasExpired){
		BetfundingProject project =	projectMapping[projectID];
		
		if(block.timestamp < project.expirationDate)
			return true;
		else 
			return false;
	}
	
	/// TODO
	function checkProjectEnd(uint256 projectID){
		BetfundingProject project =	projectMapping[projectID];
		
		if(checkExpirationDate(projectID) && getNiceBets(projectID)>1 && project.projectVerified){
			/// funcion de ponderacion para enviar el dinero a los que apostaron
		}
		else{
			uint256 numBets = 0;
			while(numBets < project.numBadGamblers){
				address a = project.badGamblers[numBets];
            	uint amount =  project.amountBets[project.badGamblers[numBets]];
				a.send(amount);
			}
		}
	}
	
	function verifyProject(uint256 projectID){
		BetfundingProject project =	projectMapping[projectID];
		
		if(checkExpirationDate(projectID) && msg.sender == project.verificationJudge)
			project.projectVerified = true;
		else
			project.projectVerified = false;
	}
	
	/** Getters */
	
	function getNiceBets(uint256 projectID) returns (uint256 amount){
		BetfundingProject project =	projectMapping[projectID];
		uint256 numBets = 1;
		amount = 0;
		
		while(numBets <= project.numNiceGamblers){
			amount +=  project.amountBets[project.niceGamblers[numBets]];
			numBets++;
		}
		
		return amount;
	}
	
	function getNumNiceBets(uint256 projectID) returns (uint256 num){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.numNiceGamblers;
	}
	
	function getBadBets(uint256 projectID) returns (uint256 amount){
		BetfundingProject project =	projectMapping[projectID];
		uint256 numBets = 1;
		amount = 0;
		
		while(numBets <= project.numBadGamblers){
			amount +=  project.amountBets[project.badGamblers[numBets]];
			numBets++;
		}
		
		return amount;
	}
	
	function getNumBadBets(uint256 projectID) returns (uint256 num){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.numBadGamblers;
	}
	
	function getNumProjects() constant returns (uint256 num){
		
		return numProjects;
	}
	
	function getProjectName(uint256 projectID) returns (string32 name){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectName;
	}
	
	function getProjectEndDate(uint256 projectID) returns (uint256 date){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.expirationDate;
	}
	
	function getProjectVerification(uint256 projectID) returns (string32 verificacion){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.verificationMethod;
	}
	
	function getProjectJudge(uint256 projectID) returns (address addr){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.verificationJudge;
	}
	
	function getProjectDescription(uint256 projectID) returns (string32 description){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectDescription;
	}
	
	function getProjectCreator(uint256 projectID) returns (address addr){
		BetfundingProject project =	projectMapping[projectID];
		
		return project.projectCreator;
	}
	
	struct BetfundingProject{
		uint256 numNiceGamblers;
		mapping(uint256 => address) niceGamblers;
		
		uint256 numBadGamblers;
		mapping(uint256 => address) badGamblers;
		
		mapping(address => uint256) amountBets;
		
		address projectCreator;
		string32 projectName;
		string32 projectDescription;
		uint256 expirationDate;
		string32 verificationMethod;
		
		bool projectVerified;
		address verificationJudge;
	}
}