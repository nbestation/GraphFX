# GraphFX
Graph Processing on FPGA with optimized crossbar structures.

The project will be developed in 3 steps:

- An NxN crossbar module which is distributed among different FPGA dies. Requirements:
    - It should provide an average throughput of N packets/cycle to avoid FIFO overflow.
    - Different column groups should be distributed to different dies.
    - Goal: completed and fully tested by December 1st.

- Source UltraRAM providing vertex data input to the crossbar; destination
UltraRAM which provides vertex data to update and accepts updates.
    - Goal: completed by December 20th.

- Edge streaming data interface from DRAM. Edge partitions are pre-calculated
and the partition metadata is stored in the front of streamed partitions.
Requiremets:
    - Our crossbar is more efficient when the src & dest vertices of sequential
    edges are out-of-ordered. Preprocessing will help shuffling the original
    datasets (by hashing).
    - The workload targeted at each UltraRAMs should be balanced. Again, this is
    done by the preprocessing.
    - Goal: Uncertain. I hope to complete coding and simulation by start of next
    semester.
