; creates a set of moves that may be used and returns its address in hl
; unused slots are filled with 0, all used slots may be chosen with equal probability
AIEnemyTrainerChooseMoves:
    ; Initialize temporary move selection array with $a
    ld a, $a
    ld hl, wBuffer
    ld [hli], a   ; move 1
    ld [hli], a   ; move 2
    ld [hli], a   ; move 3
    ld [hl], a    ; move 4

    ; Forbid disabled move if any
    ld a, [wEnemyDisabledMove]
    swap a
    and $f
    jr z, .noMoveDisabled
    ld hl, wBuffer
    dec a
    ld c, a
    ld b, $0
    add hl, bc
    ld [hl], $50  ; forbid (highly discourage) disabled move
.noMoveDisabled

    ; Load the moves from the enemy Pokémon
    ld hl, wEnemyMonMoves
    ld c, [hl]     ; Move 1
    inc hl
    ld d, [hl]     ; Move 2
    inc hl
    ld e, [hl]     ; Move 3
    inc hl
    ld h, [hl]     ; Move 4

    ; Initialize move counter
    ld l, 4
    ld a, c
    cp 0
    jr nz, .move1_exists
    dec l
.move1_exists
    ld a, d
    cp 0
    jr nz, .move2_exists
    dec l
.move2_exists
    ld a, e
    cp 0
    jr nz, .move3_exists
    dec l
.move3_exists
    ld a, h
    cp 0
    jr nz, .move4_exists
    dec l
.move4_exists

    ; Adjust probabilities based on the number of available moves
    ld hl, wPolicyMove1
    ld a, 25
    ld [hl], a
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a

    ; Adjust probabilities dynamically
    ld a, l
    cp 4
    jr nz, .adjust3
    ; No adjustment needed for 4 moves (25% each)
    jr .choose_move
.adjust3:
    cp 3
    jr nz, .adjust2
    ; Adjust probabilities for 3 moves (33% each)
    ld hl, wPolicyMove1
    ld a, 33
    ld [hl], a
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a
    ld a, 1
    ld [hl], a
    jr .choose_move
.adjust2:
    cp 2
    jr nz, .adjust1
    ; Adjust probabilities for 2 moves (50% each)
    ld hl, wPolicyMove1
    ld a, 50
    ld [hl], a
    inc hl
    ld [hl], a
    ld a, 0
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a
    jr .choose_move
.adjust1:
    ; Adjust probabilities for 1 move (100%)
    ld hl, wPolicyMove1
    ld a, 100
    ld [hl], a
    ld a, 0
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a
    inc hl
    ld [hl], a

.choose_move:
    ; Select a move based on adjusted probabilities
    ld hl, wPolicyMove1
    ld a, [hl]
    cp b
    jr c, Move1
    inc hl
    ld a, [hl]
    cp b
    jr c, Move2
    inc hl
    ld a, [hl]
    cp b
    jr c, Move3
    inc hl
    ; Default to Move 4 if it exists, otherwise fallback to an existing move
Move4:
    ld a, h
    cp 0
    jr nz, MoveFound
Move3Fallback:
    ld a, e
    cp 0
    jr nz, MoveFound
Move2Fallback:
    ld a, d
    cp 0
    jr nz, MoveFound
Move1Fallback:
    ld a, c
MoveFound:
    ret
Move3:
    ld a, e
    jr MoveFound
Move2:
    ld a, d
    jr MoveFound
Move1:
    ld a, c
    jr MoveFound

; Data section for policy probabilities
wPolicyMove1: db 25
wPolicyMove2: db 25
wPolicyMove3: db 25
wPolicyMove4: db 25

; Original AI logic
INCLUDE "data/trainers/move_choices.asm"
INCLUDE "data/trainers/pic_pointers_money.asm"
INCLUDE "data/trainers/names.asm"
INCLUDE "engine/battle/misc.asm"
INCLUDE "engine/battle/read_trainer_party.asm"
INCLUDE "data/trainers/special_moves.asm"
INCLUDE "data/trainers/parties.asm"

TrainerAI:
    and a
    ld a, [wIsInBattle]
    dec a
    ret z ; if not a trainer, we're done here
    ld a, [wLinkState]
    cp LINK_STATE_BATTLING
    ret z ; if in a link battle, we're done as well
    ld a, [wTrainerClass] ; what trainer class is this?
    dec a
    ld c, a
    ld b, 0
    ld hl, TrainerAIPointers
    add hl, bc
    add hl, bc
    add hl, bc
    ld a, [wAICount]
    and a
    ret z ; if no AI uses left, we're done here
    inc hl
    inc a
    jr nz, .getpointer
    dec hl
    ld a, [hli]
    ld [wAICount], a
.getpointer
    ld a, [hli]
    ld h, [hl]
    ld l, a
    call Random
    jp hl

INCLUDE "data/trainers/ai_pointers.asm"

JugglerAI:
    cp 25 percent + 1
    ret nc
    jp AISwitchIfEnoughMons

BlackbeltAI:
    cp 13 percent - 1
    ret nc
    jp AIUseXAttack

GiovanniAI:
    cp 25 percent + 1
    ret nc
    jp AIUseGuardSpec

CooltrainerMAI:
    cp 25 percent + 1
    ret nc
    jp AIUseXAttack

CooltrainerFAI:
    ; The intended 25% chance to consider switching will not apply.
    ; Uncomment the line below to fix this.
    cp 25 percent + 1
    ; ret nc
    ld a, 10
    call AICheckIfHPBelowFraction
    jp c, AIUseHyperPotion
    ld a, 5
    call AICheckIfHPBelowFraction
    ret nc
    jp AISwitchIfEnoughMons

BrockAI:
    ; if his active monster has a status condition, use a full heal
    ld a, [wEnemyMonStatus]
    and a
    ret z
    jp AIUseFullHeal

MistyAI:
    cp 25 percent + 1
    ret nc
    jp AIUseXDefend

LtSurgeAI:
    cp 25 percent + 1
    ret nc
    jp AIUseXSpeed

ErikaAI:
    cp 50 percent + 1
    ret nc
    ld a, 10
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseSuperPotion

KogaAI:
    cp 25 percent + 1
    ret nc
    jp AIUseXAttack

BlaineAI:
    cp 25 percent + 1
    ret nc
    jp AIUseSuperPotion

SabrinaAI:
    cp 25 percent + 1
    ret nc
    ld a, 10
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseHyperPotion

Rival2AI:
    cp 13 percent - 1
    ret nc
    ld a, 5
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUsePotion

Rival3AI:
    cp 13 percent - 1
    ret nc
    ld a, 5
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseFullRestore

LoreleiAI:
    cp 50 percent + 1
    ret nc
    ld a, 5
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseSuperPotion

BrunoAI:
    cp 25 percent + 1
    ret nc
    jp AIUseXDefend

AgathaAI:
    cp 8 percent
    jp c, AISwitchIfEnoughMons
    cp 50 percent + 1
    ret nc
    ld a, 4
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseSuperPotion

LanceAI:
    cp 50 percent + 1
    ret nc
    ld a, 5
    call AICheckIfHPBelowFraction
    ret nc
    jp AIUseHyperPotion

GenericAI:
    and a ; clear carry
    ret

; end of individual trainer AI routines

DecrementAICount:
    ld hl, wAICount
    dec [hl]
    scf
    ret

AIPlayRestoringSFX:
    ld a, SFX_HEAL_AILMENT
    jp PlaySoundWaitForCurrent

AIUseFullRestore:
    call AICureStatus
    ld a, FULL_RESTORE
    ld [wAIItem], a
    ld de, wHPBarOldHP
    ld hl, wEnemyMonHP + 1
    ld a, [hld]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    ld hl, wEnemyMonMaxHP + 1
    ld a, [hld]
    ld [de], a
    inc de
    ld [wHPBarMaxHP], a
    ld [wEnemyMonHP + 1], a
    ld a, [hl]
    ld [de], a
    ld [wHPBarMaxHP+1], a
    ld [wEnemyMonHP], a
    jr AIPrintItemUseAndUpdateHPBar

AIUsePotion:
    ; enemy trainer heals his monster with a potion
    ld a, POTION
    ld b, 20
    jr AIRecoverHP

AIUseSuperPotion:
    ; enemy trainer heals his monster with a super potion
    ld a, SUPER_POTION
    ld b, 50
    jr AIRecoverHP

AIUseHyperPotion:
    ; enemy trainer heals his monster with a hyper potion
    ld a, HYPER_POTION
    ld b, 200
    ; fallthrough

AIRecoverHP:
    ; heal b HP and print "trainer used $(a) on pokemon!"
    ld [wAIItem], a
    ld hl, wEnemyMonHP + 1
    ld a, [hl]
    ld [wHPBarOldHP], a
    add b
    ld [hld], a
    ld [wHPBarNewHP], a
    ld a, [hl]
    ld [wHPBarOldHP+1], a
    ld [wHPBarNewHP+1], a
    jr nc, .next
    inc a
    ld [hl], a
    ld [wHPBarNewHP+1], a
.next
    inc hl
    ld a, [hld]
    ld b, a
    ld de, wEnemyMonMaxHP + 1
    ld a, [de]
    dec de
    ld [wHPBarMaxHP], a
    sub b
    ld a, [hli]
    ld b, a
    ld a, [de]
    ld [wHPBarMaxHP+1], a
    sbc b
    jr nc, AIPrintItemUseAndUpdateHPBar
    inc de
    ld a, [de]
    dec de
    ld [hld], a
    ld [wHPBarNewHP], a
    ld a, [de]
    ld [hl], a
    ld [wHPBarNewHP+1], a
    ; fallthrough

AIPrintItemUseAndUpdateHPBar:
    call AIPrintItemUse_
    hlcoord 2, 2
    xor a
    ld [wHPBarType], a
    predef UpdateHPBar2
    jp DecrementAICount

AISwitchIfEnoughMons:
    ; enemy trainer switches if there are 2 or more unfainted mons in party
    ld a, [wEnemyPartyCount]
    ld c, a
    ld hl, wEnemyMon1HP

    ld d, 0 ; keep count of unfainted monsters

    ; count how many monsters haven't fainted yet
.loop
    ld a, [hli]
    ld b, a
    ld a, [hld]
    or b
    jr z, .Fainted ; has monster fainted?
    inc d
.Fainted
    push bc
    ld bc, wEnemyMon2 - wEnemyMon1
    add hl, bc
    pop bc
    dec c
    jr nz, .loop

    ld a, d ; how many available monsters are there?
    cp 2    ; don't bother if only 1
    jp nc, SwitchEnemyMon
    and a
    ret

SwitchEnemyMon:
    ; prepare to withdraw the active monster: copy hp, number, and status to roster
    ld a, [wEnemyMonPartyPos]
    ld hl, wEnemyMon1HP
    ld bc, wEnemyMon2 - wEnemyMon1
    call AddNTimes
    ld d, h
    ld e, l
    ld hl, wEnemyMonHP
    ld bc, 4
    call CopyData

    ld hl, AIBattleWithdrawText
    call PrintText

    ; This wFirstMonsNotOutYet variable is abused to prevent the player from
    ; switching in a new mon in response to this switch.
    ld a, 1
    ld [wFirstMonsNotOutYet], a
    callfar EnemySendOut
    xor a
    ld [wFirstMonsNotOutYet], a

    ld a, [wLinkState]
    cp LINK_STATE_BATTLING
    ret z
    scf
    ret

AIBattleWithdrawText:
    text_far _AIBattleWithdrawText
    text_end

AIUseFullHeal:
    call AIPlayRestoringSFX
    call AICureStatus
    ld a, FULL_HEAL
    jp AIPrintItemUse

AICureStatus:
    ; cures the status of enemy's active pokemon
    ld a, [wEnemyMonPartyPos]
    ld hl, wEnemyMon1Status
    ld bc, wEnemyMon2 - wEnemyMon1
    call AddNTimes
    xor a
    ld [hl], a ; clear status in enemy team roster
    ld [wEnemyMonStatus], a ; clear status of active enemy
    ld hl, wEnemyBattleStatus3
    res 0, [hl]
    ret

AIUseXAccuracy: ; unused
    call AIPlayRestoringSFX
    ld hl, wEnemyBattleStatus2
    set 0, [hl]
    ld a, X_ACCURACY
    jp AIPrintItemUse

AIUseGuardSpec:
    call AIPlayRestoringSFX
    ld hl, wEnemyBattleStatus2
    set 1, [hl]
    ld a, GUARD_SPEC
    jp AIPrintItemUse

AIUseDireHit: ; unused
    call AIPlayRestoringSFX
    ld hl, wEnemyBattleStatus2
    set 2, [hl]
    ld a, DIRE_HIT
    jp AIPrintItemUse

AICheckIfHPBelowFraction:
    ; return carry if enemy trainer's current HP is below 1 / a of the maximum
    ldh [hDivisor], a
    ld hl, wEnemyMonMaxHP
    ld a, [hli]
    ldh [hDividend], a
    ld a, [hl]
    ldh [hDividend + 1], a
    ld b, 2
    call Divide
    ldh a, [hQuotient + 3]
    ld c, a
    ldh a, [hQuotient + 2]
    ld b, a
    ld hl, wEnemyMonHP + 1
    ld a, [hld]
    ld e, a
    ld a, [hl]
    ld d, a
    ld a, d
    sub b
    ret nz
    ld a, e
    sub c
    ret

AIUseXAttack:
    ld b, $A
    ld a, X_ATTACK
    jr AIIncreaseStat

AIUseXDefend:
    ld b, $B
    ld a, X_DEFEND
    jr AIIncreaseStat

AIUseXSpeed:
    ld b, $C
    ld a, X_SPEED
    jr AIIncreaseStat

AIUseXSpecial:
    ld b, $D
    ld a, X_SPECIAL
    ; fallthrough

AIIncreaseStat:
    ld [wAIItem], a
    push bc
    call AIPrintItemUse_
    pop bc
    ld hl, wEnemyMoveEffect
    ld a, [hld]
    push af
    ld a, [hl]
    push af
    push hl
    ld a, XSTATITEM_DUPLICATE_ANIM
    ld [hli], a
    ld [hl], b
    callfar StatModifierUpEffect
    pop hl
    pop af
    ld [hli], a
    pop af
    ld [hl], a
    jp DecrementAICount

AIPrintItemUse:
    ld [wAIItem], a
    call AIPrintItemUse_
    jp DecrementAICount

AIPrintItemUse_:
    ; print "x used [wAIItem] on z!"
    ld a, [wAIItem]
    ld [wd11e], a
    call GetItemName
    ld hl, AIBattleUseItemText
    jp PrintText

AIBattleUseItemText:
    text_far _AIBattleUseItemText
    text_end
