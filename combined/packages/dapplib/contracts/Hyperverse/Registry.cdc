pub contract Registry {
    access(contract) var contracts: {String: Contract}

    pub fun retrieveContract(convention: String): Contract {
        return self.contracts[convention]!
    }

    pub struct Contract {
        pub let name: String
        pub let address: Address
        pub var metadata: {String: String}
        init(_name: String, _address: Address, _metadata: {String: String}) {
            self.name = _name
            self.address = _address
            self.metadata = _metadata
        }
    }

    pub resource Headmaster {
        pub fun registerContract(convention: String, address: Address, name: String, metadata: {String: String}) {
            Registry.contracts[convention] = Contract(_name: name, _address: address, _metadata: metadata)
        }
    }

    access(contract) var tenantIDs: {UInt64: Bool}
    pub fun addTenantID(tenantID: UInt64) {
        pre {
            Registry.tenantIDs[tenantID] == nil:
                "This Tenant ID already exists!"
        }
        Registry.tenantIDs
    }

    init() {
        self.contracts = {}
        self.tenantIDs = {}
        self.account.save(<- create Headmaster(), to: /storage/RegistryHeadmaster)
    }
}