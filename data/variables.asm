SECTION "NEAT Variables", WRAM0

wNEAT_EnemyHP:        ds 1
wNEAT_PlayerHP:       ds 1
wNEAT_SelectedMove:   ds 1

; Reusing existing battle state symbols
wBattleMonHP:         ds 1
wEnemyMonHP:          ds 1
wBattleMonStatus:     ds 1
wEnemyMonStatus:      ds 1

wValidatedMove:       ds 1  ; Added wValidatedMove

; Define memory locations for random byte generation
SomeMemoryLocation:   ds 1
AnotherMemoryLocation: ds 1
