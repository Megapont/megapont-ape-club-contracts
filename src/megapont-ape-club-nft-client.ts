import { Tx, types, Account } from "./deps.ts";

export function flipMintpassSale(address: string) {
  return Tx.contractCall(
    "megapont-ape-club-nft",
    "flip-mintpass-sale",
    [],
    address
  );
}

export function flipSale(address: string) {
  return Tx.contractCall("megapont-ape-club-nft", "flip-sale", [], address);
}

export function claim(address: string) {
  return Tx.contractCall("megapont-ape-club-nft", "claim", [], address);
}

export function claimTwo(address: string) {
  return Tx.contractCall("megapont-ape-club-nft", "claim-two", [], address);
}

export function claimFive(address: string) {
  return Tx.contractCall("megapont-ape-club-nft", "claim-five", [], address);
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
