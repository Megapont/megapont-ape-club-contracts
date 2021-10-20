import { Account } from "./deps.ts";
export function addStxTransferAmount(events: any[], user: Account) {
  return events.reduce(
    (sum, e) =>
      e.type === "stx_transfer_event" &&
      e.stx_transfer_event.sender === user.address
        ? parseInt(e.stx_transfer_event.amount) + sum
        : sum,
    0
  );
}
