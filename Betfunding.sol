contract Betfunding {
	 
    function Betfunding() {
        numProjects = 0;
    }
    
    /** 
     * Crea un proyecto desde la direccion de la persona que lo propone
    */
    function createProject(address proponent,
						   string32 _projectName,
                           string32 _projectDesciption,
                           uint256 _expirationDate,
                           string32 _verificationMethod,
						   address _judge){
        //crea el proyecto y guardar en projectAdress
		numProjects += 1;
		BetfundingProject newProject = projectMapping[numProjects];
        newProject.projectName = _projectName;
		newProject.projectDesciption =_projectDesciption;
		newProject.expirationDate = _expirationDate;
		newProject.verificationMethod = _verificationMethod;
		newProject.verificationJudge = _judge;
    }
    
    /**
     * Map para llevar la cuenta de los proyectos
    */
    mapping(uint256 => BetfundingProject) projectMapping;
    
    uint256 numProjects;

	
	
	/** FUNCIONES DE LOS PROYECTOS **/
    
    function bid(uint256 projectID ,bool isNiceBet){
		BetfundingProject project =	projectMapping[projectID];
        if(isNiceBet){
            project.numNiceGamblers+=1; 
            project.niceGamblers[project.numNiceGamblers]=msg.sender;
            project.amountBets[msg.sender]=msg.value;
        }
        else{
            project.numBadGamblers+=1;
            project.badGamblers[project.numBadGamblers]=msg.sender;
            project.amountBets[msg.sender]=msg.value;
        }
    }
	 
	function checkExpirationDate(uint256 projectID) returns (bool hasExpired){
		BetfundingProject project =	projectMapping[projectID];
		if(block.timestamp < project.expirationDate)
			return true;
		else 
			return false;
	}
	 
	function checkProjectEnd(uint256 projectID){
		BetfundingProject project =	projectMapping[projectID];
		if( checkExpirationDate(projectID) && getNiceBets(projectID)>1 && project.projectVerified){
			//funcion de ponderacion para enviar el dinero a los que apostaron
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
    
    function getNiceBets(uint256 projectID) returns (uint256 amount){
		BetfundingProject project =	projectMapping[projectID];
        uint256 numBets = 0;
        amount = 0;
        while(numBets < project.numNiceGamblers){
            amount +=  project.amountBets[project.niceGamblers[numBets]];
			numBets++;
        }
        return amount;
    }
    
    function getBadBets(uint256 projectID) returns (uint256 amount){
		BetfundingProject project =	projectMapping[projectID];
        uint256 numBets = 0;
        amount = 0;
        while(numBets < project.numBadGamblers){
            amount +=  project.amountBets[project.badGamblers[numBets]];
			numBets++;
        }
        return amount;
    }
	 
	 
	function verifyProject(uint256 projectID){
		BetfundingProject project =	projectMapping[projectID];
		if( checkExpirationDate(projectID) && msg.sender == project.verificationJudge){
			project.projectVerified=true;
		}
		else
			project.projectVerified=false;
	}
	 
	struct BetfundingProject{
	    uint256 numNiceGamblers;
	    mapping(uint256 => address) niceGamblers;
	
    	uint256 numBadGamblers;
    	mapping(uint256 => address) badGamblers;
    	mapping(address => uint256) amountBets;
    
    	uint256 numProjects;
    	string32 projectName;
    	string32 projectDesciption;
    	uint expirationDate;
    	string32 verificationMethod;
	 
		bool projectVerified;
		address verificationJudge;
	}
}