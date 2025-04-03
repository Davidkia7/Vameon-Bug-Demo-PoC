# Token Vulnerability in transferWithFee

## Brief DescriptionThe 
`transferWithFee` function in the Vameon contract does not verify whether the sender's balance is sufficient to cover `value` + `fee` before the transfer execution begins. This causes the transaction to fail with an `ERC20InsufficientBalance` error in the middle of execution, without giving any clear advance warning to the user. If the sender's balance is insufficient for any of the transfers, the internal _transfer function of OpenZeppelin ERC-20 will trigger an ERC20InsufficientBalance error, causing the entire transaction to be reverted. While there is no loss of value due to Solidity's revert mechanism, the lack of an advance check leads to unexpected logic execution, which can be confusing for users or applications that rely on this contract.

## Vulnerability Details

### How the Vulnerability Works
- The `transferWithFee` function immediately executes two `_transfer` calls without verifying the total balance (`value` + `fee`).
- If the sender's balance is insufficient, either `_transfer` will trigger an `ERC20InsufficientBalance` error, which then causes the transaction to be completely reverted.

### Process
1. User calls `transferWithFee` with `value` and `fee` that total more than their balance.
2. The transaction is initiated, but fails midway due to the sender's insufficient balance.
3. **Technical Result:** Transactions are fully reverted, but gas is still wasted and users receive no clear early warning.

## Impact of Vulnerability

### Effect on Users
- **Wasted Gas:** Failed transactions still burn gas.
- **Confusion:** The generic error (`ERC20InsufficientBalance`) does not explain that the balance is insufficient for `value` + `fee`.

### Effect on System
- **Reduced Reliability:** The `transferWithFee` function becomes less reliable due to unexpected failures.
- **Integration Difficulty:** Application integration becomes more difficult because it must handle failures reactively.

### Nature of the Outage
- **No Loss of Value:** Transactions are fully reverted, so no funds are lost.
- **UX and Efficiency Issues:** This outage is purely a user experience and system efficiency issue, with no risk of theft.

## How to Test (Step by Step)
Here are the steps to test for this vulnerability using [Remix IDE](https://remix.ethereum.org/), a free, browser-based tool.

### What You Need
- A web browser to open Remix.
- No additional software is needed—use Remix’s built-in test environment.

# Testing for Token Vulnerability in transferWithFee

This documentation describes the steps to test for a vulnerability in the `transferWithFee` function in the Vameon contract using Remix IDE. The vulnerability occurs because there is no initial check for sufficient balance before initiating a transfer, so if the sender’s balance is insufficient to cover `value` + `fee`, the transaction fails midway with an `ERC20InsufficientBalance` error.

---

## Steps in Remix

### 1. Open Remix IDE
- Visit [Remix Ethereum IDE](https://remix.ethereum.org).

### 2. Compile the Contract
In the **"Solidity Compiler"** tab:
- Select the compiler version **0.8.20**.
- Compile the `Vameon.sol` and `TestVameon.sol` files sequentially.

### 3. Deploy the Vameon Contract
In the **"Deploy & Run Transactions"** tab:
- Select the **"JavaScript VM (London)"** environment.
- Deploy the `Vameon` contract with the following parameters:
- `_tokensHolder`: Account 0 (example: `0x5B38...C2Ed`)
- `_feeCollector`: Account 1 (example: `0xAb84...dD8b`)
- `_trustedForwarder`: Account 2 (example: `0xCA35...F509`)
- **Note the generated Vameon contract address**.

### 4. Deploy TestVameon Contract
- Deploy the `TestVameon` contract with the following parameters:
- `_vameonAddress`: The address of the deployed Vameon contract.
- **Save the TestVameon contract address** for the next testing step.

### 5. Prepare the Balance
From account 0 (initial sender):
- Transfer tokens to the `TestVameon` contract.
- In the `Vameon` contract, call the `transfer` function with the following parameters:
- `to`: The `UnrestrictedFeeDrain` address.
- `value`: **100**
- Verify the balance on `TestVameon` by calling the `getBalance` function. The balance that appears should be **100**.

### 6. Run Proof of Concept (PoC)
On the `TestVameon` contract:
- Call the `testTransferWithFee` function with the following parameters:
- `to`: Account 2 (example: `0xCA35...F509`)
- `value`: **90**
- `fee`: **20**
- Click the **"transact"** button.

**Expected Result:**
The transaction fails and returns an error like this:
```transact to TestVameon.testTransferWithFee errored: Error occurred: revert.

revert
The transaction has been reverted to the initial state.
Error provided by the contract:
ERC20InsufficientBalance
Parameters:
{
 "sender": {
 "value": "0xC4FA8Ef3914b2b09714Ebe35D1Fb101F98aAd13b",
 "documentation": "Address whose tokens are being transferred."
 },
 "balance": {
 "value": "10",
 "documentation": "Current balance for the interacting account."
 },
 "needed": {
 "value": "20",
 "documentation": "Minimum amount required to perform a transfer."
 }
}
If the transaction fails for not having enough gas, try increasing the gas limit gently.```
