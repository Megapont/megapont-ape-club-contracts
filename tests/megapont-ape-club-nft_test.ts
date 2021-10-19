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
  name: "Ensure that NFT token URL and ID is as expected",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let wallet_1 = accounts.get("wallet_1")!;
    let block = chain.mineBlock([
      Tx.contractCall(
        "megapont-ape-club-nft",
        "get-last-token-id",
        [],
        wallet_1.address
      ),
      Tx.contractCall(
        "megapont-ape-club-nft",
        "get-token-uri",
        [types.uint(1)],
        wallet_1.address
      ),
    ]);
    assertEquals(block.receipts.length, 2);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(0);
    block.receipts[1].result
      .expectOk()
      .expectSome()
      .expectAscii(
        "ipfs://Qmad43sssgNbG9TpC6NfeiTi9X6f9vPYuzgW2S19BEi49m/{id}"
      );
  },
});

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
  name: "Ensure that benefials can't mint",
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
