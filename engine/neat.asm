SECTION "NEAT Initialization", ROMX

InitPopulation:
    ld hl, NEAT_Population
    ld bc, NEAT_PopulationSize * NEAT_NumWeights
    call RandomizePopulation
    ret

RandomizePopulation:
    ; Randomize bc bytes starting from hl
    ld de, 0
RandLoop:
    call RandomByte
    ld [hli], a
    inc de
    ld a, e
    cp c
    jr nz, RandLoop
    ld a, d
    cp b
    jr nz, RandLoop
    ret

RandomByte:
    ; Generate a random byte in a (simple RNG for demonstration)
    ld a, [SomeMemoryLocation]
    xor a, [AnotherMemoryLocation]
    ret
