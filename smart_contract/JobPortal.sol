// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JobPortal {
    address payable admin;

    struct ApplicantInfo {
        uint256 id;
        string name;
        uint experienceInYears;
        string[] skills;
        bool availability;
        address applicantAddress;
        uint256[] rating;
    }

    struct JobInfo {
        uint256 id;
        string title;
        string description;
        uint256 salary;
        uint256 minExperience;
        address company;
        uint256[] applicantsIdThatApplied;
        bool hired;
    }

    struct ApplicationStatus{
        uint applicantId;
        bool applicantHired;
    }

    // ApplicantInfo[] applicants;
    mapping(uint256 => ApplicantInfo)  applicantsDetails;
    mapping(address => ApplicationStatus) applicants;
    mapping(uint256 => JobInfo)   jobs;
    mapping(address => mapping(uint => bool))  applicantRatings;
    mapping(address => bool) jobProviders;

    uint256  applicantCount = 1;
    uint256  jobCount = 1;

    constructor() {
        admin = payable(msg.sender);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can add applicants, to reduce fraudulent registration of applicants ");
        _;
    }

    function addApplicant(string memory _name,uint _experience,string[] memory _skills, address _applicantAddress ) public onlyAdmin{
       applicantsDetails[applicantCount] = ApplicantInfo(applicantCount,_name,_experience,_skills,false,_applicantAddress,new uint[](0));
       applicants[_applicantAddress] = ApplicationStatus(applicantCount,true);
       applicantCount++;
    }

    function getApplicantDetails(uint256 _applicantId) public view returns (uint256, string memory, uint, string[] memory, bool, address, uint256[] memory) {
        return (
            applicantsDetails[_applicantId].id,
            applicantsDetails[_applicantId].name,
            applicantsDetails[_applicantId].experienceInYears,
            applicantsDetails[_applicantId].skills,
            applicantsDetails[_applicantId].availability,
            applicantsDetails[_applicantId].applicantAddress,
            applicantsDetails[_applicantId].rating
        );

    }

    function addJob(string memory _title, string memory _description,uint _experienceNeeded,  uint256 _salary) payable public {
        require(msg.value == 1 ether,"Please pay 1 ether");
        jobProviders[msg.sender] = true;
        jobs[jobCount] = JobInfo(jobCount, _title, _description, _salary, _experienceNeeded, msg.sender, new uint256[](0),false);
        jobCount++;
    }

    function getJobDetails(uint256 _jobId) public view returns (string memory,string memory,uint256 ,uint256 ,uint[] memory,address) {
        return (
            jobs[_jobId].title,
            jobs[_jobId].description,
            jobs[_jobId].salary,
            jobs[_jobId].minExperience,
            jobs[_jobId].applicantsIdThatApplied,
            jobs[_jobId].company
        );
    }


    function applyForJob(uint256 _jobId) public {
        require(applicants[msg.sender].applicantHired == true, "You are not an applicant");
        require(_jobId < jobCount,"Please enter valid job id");

        for (uint i=0;i<(jobs[_jobId].applicantsIdThatApplied).length;i++){
            require(applicants[msg.sender].applicantId != jobs[_jobId].applicantsIdThatApplied[i],"You have already applied");
        }
        (jobs[_jobId].applicantsIdThatApplied).push(applicants[msg.sender].applicantId);
    }

    function hireApplicant(uint _jobId, uint _applicantId) public {
        require(jobProviders[msg.sender] == true,"You are not job provider");
        require(_jobId < jobCount ,"Job id entered does not exist, Please enter correct job id");
        require(jobs[_jobId].company == msg.sender,"Please enter your own job id, you cannot hire on someone else's behalf");
        require(_applicantId < applicantCount," Applicant id entered does not exist, Please enter correct Applicant id");
        require(applicantsDetails[_applicantId].availability == false,"Applicant has already been hired");
        applicantsDetails[_applicantId].availability = true;
    }


    function provideRating(uint256 _jobId,uint256 _applicantId, uint256 _rating) public {
        require(jobProviders[msg.sender] == true,"You are not job provider");
        require(_jobId < jobCount ,"Job id entered does not exist, Please enter correct job id");
        require(applicantRatings[msg.sender][_jobId] == false,"You have already provided rating for this job");
        require(jobs[_jobId].company == msg.sender,"Please enter your own job id, you cannot hire on someone else's behalf");
        require(_applicantId < applicantCount," Applicant id entered does not exist, Please enter correct Applicant id");
        require(_rating <= 5 ,"Applicant is rated from 1 to 5");
        
        (applicantsDetails[_applicantId].rating).push(_rating);
        applicantRatings[msg.sender][_jobId] = true;
    }
}