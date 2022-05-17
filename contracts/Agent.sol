pragma solidity ^0.5.1;

contract Agent {
    struct patient {
        string name;
        uint256 age;
        address[] doctorAccessList;
        uint256[] diagnosis;
        string record;
        string[] report;
    }

    struct doctor {
        string name;
        uint256 age;
        address[] patientAccessList;
    }

    uint256 creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping(address => patient) patientInfo;
    mapping(address => doctor) doctorInfo;
    mapping(address => address) Empty;
    // might not be necessary
    mapping(address => string) patientRecords;

    function add_agent(
        string memory _name,
        uint256 _age,
        uint256 _designation,
        string memory _hash
    ) public returns (string memory) {
        address addr = msg.sender;

        if (_designation == 0) {
            patient memory p;
            p.name = _name;
            p.age = _age;
            p.record = _hash;
            patientInfo[msg.sender] = p;
            patientList.push(addr) - 1;
            return _name;
        } else if (_designation == 1) {
            doctorInfo[addr].name = _name;
            doctorInfo[addr].age = _age;
            doctorList.push(addr) - 1;
            return _name;
        } else {
            revert();
        }
    }

    function get_patient(address addr)
        public
        view
        returns (
            string memory,
            uint256,
            uint256[] memory,
            address,
            string memory,
            string memory

        )
    {
        // if(keccak256(patientInfo[addr].name) == keccak256(""))revert();
        return (
            patientInfo[addr].name,
            patientInfo[addr].age,
            patientInfo[addr].diagnosis,
            Empty[addr],
            patientInfo[addr].record,
            patientInfo[addr].report

        );
    }

    function get_doctor(address addr)
        public
        view
        returns (string memory, uint256)
    {
        // if(keccak256(doctorInfo[addr].name)==keccak256(""))revert();
        return (doctorInfo[addr].name, doctorInfo[addr].age);
    }

    function get_patient_doctor_name(address paddr, address daddr)
        public
        view
        returns (string memory, string memory)
    {
        return (patientInfo[paddr].name, doctorInfo[daddr].name);
    }

    function permit_access(address addr) public payable {
        require(msg.value == 2 ether);

        creditPool += 2;

        doctorInfo[addr].patientAccessList.push(msg.sender) - 1;
        patientInfo[msg.sender].doctorAccessList.push(addr) - 1;
    }

    //must be called by doctor
    function insurance_claim(
        address paddr,
        uint256 _diagnosis,
        string memory _hash
    ) public {
        bool patientFound = false;
        for (
            uint256 i = 0;
            i < doctorInfo[msg.sender].patientAccessList.length;
            i++
        ) {
            if (doctorInfo[msg.sender].patientAccessList[i] == paddr) {
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;
            }
        }
        if (patientFound == true) {
            set_hash(paddr, _hash);
            remove_patient(paddr, msg.sender);
        } else {
            revert();
        }

        bool DiagnosisFound = false;
        for (uint256 j = 0; j < patientInfo[paddr].diagnosis.length; j++) {
            if (patientInfo[paddr].diagnosis[j] == _diagnosis)
                DiagnosisFound = true;
        }
    }

    function remove_element_in_array(address[] storage Array, address addr)
        internal
        returns (uint256)
    {
        bool check = false;
        uint256 del_index = 0;
        for (uint256 i = 0; i < Array.length; i++) {
            if (Array[i] == addr) {
                check = true;
                del_index = i;
            }
        }
        if (!check) revert();
        else {
            if (Array.length == 1) {
                delete Array[del_index];
            } else {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];
            }
            Array.length--;
        }
    }

    function remove_patient(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
    }

    function get_accessed_doctorlist_for_patient(address addr)
        public
        view
        returns (address[] memory)
    {
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }

    function get_accessed_patientlist_for_doctor(address addr)
        public
        view
        returns (address[] memory)
    {
        return doctorInfo[addr].patientAccessList;
    }

    function revoke_access(address daddr) public payable {
        remove_patient(msg.sender, daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }

    function get_patient_list() public view returns (address[] memory) {
        return patientList;
    }

    function get_doctor_list() public view returns (address[] memory) {
        return doctorList;
    }

    function get_hash(address paddr) public view returns (string memory) {
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }
    function set_report(string memory _memeHash) public {
    address addr = msg.sender;
    patientInfo[addr].report.push(_memeHash);

    }

  function get_report() public view returns (string memory) {
    address addr = msg.sender;
    return patientInfo[addr].report;

     }
}
