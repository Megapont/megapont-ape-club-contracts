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
  claim,
  getBalance,
  getMintpassBalance,
} from "../src/megapont-ape-club-nft-client.ts";
import { addStxTransferAmount } from "../src/utils.ts";

Clarinet.test({
  name: "Ensure that presale mint and public mint can happen",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;

    let mintpasses = getMintpassBalance(chain, wallet_5);
    mintpasses.result.expectUint(4);

    let block = chain.mineBlock([
      flipMintpassSale(deployer.address),
      claim(wallet_5.address),
    ]);
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    let price = addStxTransferAmount(block.receipts[1].events, wallet_5);
    assertEquals(price, 50_000_000);

    let balance = getBalance(chain, wallet_5);
    balance.result.expectInt(1);

    // one mintpass has been used
    mintpasses = getMintpassBalance(chain, wallet_5);
    mintpasses.result.expectUint(3);

    block = chain.mineBlock([
      flipSale(deployer.address),
      claimFive(wallet_5.address),
    ]);
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    price = addStxTransferAmount(block.receipts[1].events, wallet_5);
    assertEquals(price, 250_000_000);

    balance = getBalance(chain, wallet_5);
    balance.result.expectInt(6);

    // no mint passes have been used
    mintpasses = getMintpassBalance(chain, wallet_5);
    mintpasses.result.expectUint(3);
  },
});

Clarinet.test({
  name: "Ensure that minting fails while mintpass and public mint disabled",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([claim(wallet_5.address)]);
    block.receipts[0].result.expectErr().expectUint(500);
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
    block.receipts[1].result.expectErr().expectUint(2);
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
    block.receipts[0].result.expectErr().expectUint(500);
    block.receipts[1].result.expectOk().expectBool(true);
    block.receipts[2].result.expectOk().expectBool(true);
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
    block.receipts[0].result.expectErr().expectUint(500);
    block.receipts[1].result.expectOk().expectBool(true);
    block.receipts[2].result.expectOk().expectBool(true);
  },
});


Clarinet.test({
  name: "Ensure that users can't mint more NFTs than they own mintpasses",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet_5 = accounts.get("wallet_5")!;
    let block = chain.mineBlock([
      flipMintpassSale(deployer.address),
      claimFive(wallet_5.address),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
    block.receipts[1].result.expectErr().expectUint(501);
  },
});
