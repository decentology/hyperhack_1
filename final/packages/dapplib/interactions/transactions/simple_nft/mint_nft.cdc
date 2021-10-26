import SimpleNFT from 0x26a365de6d6237cd

transaction(recipient: Address, tenantID: String, name: String) {

    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {

        let SignerSimpleNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleNFT.Package.")

        self.SimpleNFTMinter = SignerSimpleNFTPackage.borrowMinter(tenantID: tenantID)

        let RecipientSimpleNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                            .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Package.")
        self.RecipientCollection = RecipientSimpleNFTPackage.borrowCollectionPublic(tenantID: tenantID)
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(metadata: {"name": name}) 
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}
