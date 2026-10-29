// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../SimpleToken.sol";

/// @dev Small regression suite with no external Solidity test-library dependency.
contract SimpleTokenTest {
    function testInitialSupplyIsAssignedToReceiver() public {
        SimpleToken token = new SimpleToken(address(this));
        require(token.totalSupply() == 1_000_000 * 10 ** 18, "unexpected total supply");
        require(token.balanceOf(address(this)) == token.totalSupply(), "receiver balance mismatch");
        require(token.decimals() == 18, "unexpected decimals");
    }

    function testConstructorRejectsZeroReceiver() public {
        bool reverted;
        try new SimpleToken(address(0)) returns (SimpleToken deployed) {
            deployed;
        } catch {
            reverted = true;
        }
        require(reverted, "constructor accepted zero receiver");
    }

    function testTransferRejectsZeroRecipient() public {
        SimpleToken token = new SimpleToken(address(this));
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(SimpleToken.transfer.selector, address(0), uint256(1))
        );
        require(!success, "transfer accepted zero recipient");
    }

    function testApproveRejectsZeroSpender() public {
        SimpleToken token = new SimpleToken(address(this));
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(SimpleToken.approve.selector, address(0), uint256(1))
        );
        require(!success, "approve accepted zero spender");
    }

    function testTransferFromRejectsZeroSource() public {
        SimpleToken token = new SimpleToken(address(this));
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                SimpleToken.transferFrom.selector,
                address(0),
                address(0xBEEF),
                uint256(1)
            )
        );
        require(!success, "transferFrom accepted zero source");
    }

    function testTransferFromRejectsZeroRecipient() public {
        SimpleToken token = new SimpleToken(address(this));
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                SimpleToken.transferFrom.selector,
                address(this),
                address(0),
                uint256(1)
            )
        );
        require(!success, "transferFrom accepted zero recipient");
    }

    function testTransferMovesTokensNormally() public {
        SimpleToken token = new SimpleToken(address(this));
        address recipient = address(0xBEEF);
        uint256 amount = 100;
        require(token.transfer(recipient, amount), "transfer returned false");
        require(token.balanceOf(address(this)) == token.totalSupply() - amount, "sender balance mismatch");
        require(token.balanceOf(recipient) == amount, "recipient balance mismatch");
    }

    function testTransferFromMovesTokensAndConsumesAllowance() public {
        SimpleToken token = new SimpleToken(address(this));
        address recipient = address(0xBEEF);
        uint256 amount = 100;
        require(token.approve(address(this), amount), "approve returned false");
        require(token.transferFrom(address(this), recipient, amount), "transferFrom returned false");
        require(token.balanceOf(recipient) == amount, "recipient balance mismatch");
        require(token.allowance(address(this), address(this)) == 0, "allowance was not reduced");
    }
}
