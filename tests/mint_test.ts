import {
  assertEquals,
  Clarinet,
  Tx,
  Chain,
  Account,
  types,
} from "../src/deps.ts";
import {
  flipMintpassSale,
  flipSale,
  claimFive,
  claimTwo,
  claim
} from "../src/megapont-ape-club-nft-client.ts";

Clarinet.test({
  name: "Ensure that presale mint and public mint can happen",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      flipMintpassSale(deployer.address),
      claim(wallet_5.address),
    ])
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();

    block = chain.mineBlock([
      flipSale(deployer.address),
      claimFive(wallet_5.address),
    ]);
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
  },
});

Clarinet.test({
  name: "Ensure that minting fails while mintpass and public mint disabled",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      claim(wallet_5.address),      
    ]);
    block.receipts[0].result.expectErr().expectUint(500)
  },
});

Clarinet.test({
  name: "Ensure that beneficials can't mint",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_1 = accounts.get("wallet_1")!;
    let block = chain.mineBlock([
      flipSale(deployer.address),
      claim(wallet_1.address),      
    ]);
    block.receipts[1].result.expectErr().expectUint(2)
  },
});

Clarinet.test({
  name: "Ensure that users can only mint after sale is activated",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      claim(wallet_5.address),      
      flipSale(deployer.address),
      claim(wallet_5.address),      
    ]);
    block.receipts[0].result.expectErr().expectUint(500)
    block.receipts[1].result.expectOk().expectBool(true)
    block.receipts[2].result.expectOk().expectBool(true)
  },
});


Clarinet.test({
  name: "Ensure that users can only mint after mintpass sale is activated",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      claim(wallet_5.address),      
      flipMintpassSale(deployer.address),
      claim(wallet_5.address),      
    ]);
    block.receipts[0].result.expectErr().expectUint(500)
    block.receipts[1].result.expectOk().expectBool(true)
    block.receipts[2].result.expectOk().expectBool(true)
  },
});
