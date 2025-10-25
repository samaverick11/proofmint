ProofMint Smart Contract

**ProofMint** is an on-chain **Proof-of-Creation and NFT Minting System** built on the **Stacks blockchain** using **Clarity**.  
It provides creators and collectors with a transparent, verifiable, and decentralized way to register, mint, and verify ownership of digital assets.

---

Features

- **Proof-of-Creation** — Timestamp and register digital assets immutably on-chain.  
- **NFT Minting (SIP-009 Compliant)** — Generate verifiable NFTs tied to creator identity.  
- **Ownership Verification** — Anyone can confirm the authenticity and current holder of an asset.  
- **Secure Transfers** — Ensures trustless, transparent asset transfers between users.  
- **Timestamp Tracking** — Each NFT includes block-based proof of creation and ownership history.  

---

Smart Contract Details

| Property | Description |
|-----------|--------------|
| **Contract Name** | `proofmint.clar` |
| **Language** | Clarity |
| **Framework** | Clarinet |
| **Blockchain** | Stacks |
| **Category** | NFT / Proof-of-Creation |

---

Functions Overview

| Function | Access | Description |
|-----------|--------|-------------|
| `register-asset` | Public | Registers a digital asset and links it to the creator’s principal. |
| `mint-nft` | Public | Mints an NFT as proof of ownership for the registered asset. |
| `verify-ownership` | Read-Only | Returns current ownership details of an NFT. |
| `transfer-nft` | Public | Transfers ownership from one user to another. |

---

Testing

You can test the smart contract using **Clarinet**:

```bash
clarinet check
clarinet test
