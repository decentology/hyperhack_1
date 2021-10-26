import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction() {
    let NFTMarketplacePackage: &NFTMarketplace.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's NFTMarketplace.Package
        self.NFTMarketplacePackage = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                                ?? panic("Could not get the NFTMarketplace.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        let UID <- HyperverseModule.createUID()
        NFTMarketplace.instance(package: self.NFTMarketplacePackage, uid: &UID as &HyperverseModule.UniqueID)
        destroy UID
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}