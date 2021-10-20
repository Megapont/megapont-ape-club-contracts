import { Chain, Tx, types, Account } from "./deps.ts";

export function flipMintpassSale(address: string) {
  return Tx.contractCall(
    "megapont-ape-club-mint",
    "flip-mintpass-sale",
    [],
    address
  );
}

export function flipSale(address: string) {
  return Tx.contractCall("megapont-ape-club-mint", "flip-sale", [], address);
}

export function claim(address: string) {
  return Tx.contractCall("megapont-ape-club-mint", "claim", [], address);
}

export function claimTwo(address: string) {
  return Tx.contractCall("megapont-ape-club-mint", "claim-two", [], address);
}

export function claimFive(address: string) {
  return Tx.contractCall("megapont-ape-club-mint", "claim-five", [], address);
}

export function transfer(
  id: number,
  sender: Account,
  recipient: Account,
  user?: Account
) {
  return Tx.contractCall(
    "megapont-ape-club-nft",
    "transfer",
    [
      types.uint(id),
      types.principal(sender.address),
      types.principal(recipient.address),
    ],
    user ? user.address : sender.address
  );
}

export function getBalance(chain: Chain, user: Account) {
  return chain.callReadOnlyFn(
    "megapont-ape-club-nft",
    "get-balance",
    [types.principal(user.address)],
    user.address
  );
}

export function list(
  id: number,
  price: number,
  commission: string,
  user: Account
) {
  return Tx.contractCall(
    "megapont-ape-club-nft",
    "list-in-ustx",
    [types.uint(id), types.uint(price), types.principal(commission)],
    user.address
  );
}

export function unlist(id: number, user: Account) {
  return Tx.contractCall(
    "megapont-ape-club-nft",
    "unlist-in-ustx",
    [types.uint(id)],
    user.address
  );
}

export function buy(id: number, commission: string, user: Account) {
  return Tx.contractCall(
    "megapont-ape-club-nft",
    "buy-in-ustx",
    [types.uint(id), types.principal(commission)],
    user.address
  );
}

export function getMintpassBalance(chain: Chain, user: Account) {
  return chain.callReadOnlyFn(
    "megapont-ape-club-mint",
    "get-presale-balance",
    [types.principal(user.address)],
    user.address
  );
}
