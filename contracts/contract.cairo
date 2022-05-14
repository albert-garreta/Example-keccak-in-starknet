# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_nn
# New library from v0.8.2
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak

@view
func hash{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}() -> (res : Uint256):
    alloc_locals
    
    #
    let (local keccak_ptr_start) = alloc()
    let keccak_ptr = keccak_ptr_start

    let elements : felt* = alloc()
    assert [elements] = 1000
    assert [elements + 1] = 10001111

    # Run as many keccaks as you want, pass keccak_ptr implicitly
    let (res) = keccak_felts{keccak_ptr=keccak_ptr}(n_elements=2, elements=elements)
    
    # Call finalize once at the end to verify the soundness of the execution
    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr)

    return (res)
end

