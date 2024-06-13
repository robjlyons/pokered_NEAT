SECTION "NEAT Data Definitions", WRAM0

; NEAT related data
wNEAT_EnemyHP:        ds 1
wNEAT_PlayerHP:       ds 1
wNEAT_EnemyMoves:     ds 4
wNEAT_EnemyStatus:    ds 1
wNEAT_PlayerStatus:   ds 1
wNEAT_SelectedMove:   ds 1
wNEAT_BattleMonStatus: ds 1
wNEAT_EnemyMonStatus: ds 1
wNEAT_wBattleMonHP:   ds 1
wValidatedMove:       ds 1  ; Define wValidatedMove

; Define memory locations for random byte generation
SomeMemoryLocation:   ds 1
AnotherMemoryLocation: ds 1

; Define battle state symbols
wPlayerMonHP:         ds 1
wEnemyMonHP:          ds 1
wPlayerStatus:        ds 1
wEnemyStatus:         ds 1
