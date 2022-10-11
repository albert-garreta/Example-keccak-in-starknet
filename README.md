# Example usage of the keccak256 hash in StarkNet

Example of how the keccak256 hash can be used within a StarkNet contract. This is a new feature from the most recent update `0.8.2`. The repo uses nile's framework.

Additionally, I try to provide an explanation of why the hash is meant to be used the way it is, without getting too much into technicalities.

**NOTE 1:** Most likely there are and will be other updates that follow a similar design pattern

**NOTE 2:** Any feedback is extremely welcome!

The high level overview of how to compute a keccak256 hash in StarkNet is the following:

## Steps

### Step 1

- Create an array of felts called `keccak_ptr`. This is where the outputs of the hash functions will be stored.

- Save the starting point of `keccak_ptr` (we will need this when calling `finalize_keccak`)

- Call any of the keccak functions (except `finalize_keccak`) as many times as wanted: e.g. `keccak` or `keccak_felts`. The outputs of the functions are stored in the array `keccak_ptr`. Furthermore the inputs and other intermediate data are also stored within this array (the reason for this will be clear later).

### Step 2

- When done, call `finalize_keccak` to verify the soundness of the execution. Here we pass the bounds of the `keccak_ptr` array. The function will extract the data to be hashed from this array, compute the hash, and check that it matches the hash stored in the array. This makes the whole process sound.

## Why this design?

The keccak functions `keccak`, `keccak_felts`, etc. are basically computing the hash using a python hint, and storing the results into memory. This is not a sound operation.

On the other hand, `finalize_keccak` is a function that computes the keccak hash natively within Cairo, and verifies that the keccak computed previously is the expected hash. This makes Step 1 + Step 2 a sound process.

The question is: why not just compute the hashes natively in the first place, and forget about the hints? The reason is the following: while executing `keccak`, `keccak_felts`, etc. these functions store different intermediate 64 bit words into the array `keccak_ptr`. Moreover, instead of using one felt per word, the functions store 3 words in each felt (since a felt is 251 bits long). Later, this is used by `finalize_keccak` to compute the hash of 3 chunks of data at once, instead of 1.

**Not sure of the following** Moreover, the different words stored in one felt do not correspond to the same "timeline": More precisely, if one calls `keccak(very_long_message)` and then calls `finalize_keccak`, then `finalize_keccak` verifies the hashes of `chunk1_of_very_long_message`, `chunk2_of_very_long_message`, and `chunk3_of_very_long_message` in parallel.


