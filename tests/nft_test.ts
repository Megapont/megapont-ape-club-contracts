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
  claim,
  transfer,
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
  name: "Ensure that users can transfer own nft",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_1 = accounts.get("wallet_1")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      flipMintpassSale(deployer.address),
      claim(wallet_5.address),
      transfer(1, wallet_5, wallet_1),
    ]);
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    block.receipts[2].result.expectOk();
  },
});

Clarinet.test({
  name: "Ensure that users can't transfer other nft",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_1 = accounts.get("wallet_1")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      flipMintpassSale(deployer.address),
      claim(wallet_5.address),
      transfer(1, wallet_5, wallet_1, deployer),
    ]);
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    block.receipts[2].result.expectErr().expectUint(401);
  },
});
