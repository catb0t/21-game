USING: 21-game 21-game.private arrays calendar io kernel math namespaces pairs threads random ;
IN: 21-game.botwars

CONSTANT: another-computer-intro "\t<Another Computer>: "
CONSTANT: another-prompt-text "Another 1 or 2? "
CONSTANT: another-win "You lose! I am the best of the bad bots!"

SINGLETONS: another-computer no-rest ;

INSTANCE: another-computer player

M: no-rest sleep-sec drop ;
no-rest rest-time set-global

M: another-computer says drop another-computer-intro writefl ;

M: another-computer human-prompt
    drop another-prompt-text writefl ;

M: another-computer <21-base-game>
    computer 2array <21-base-game> ;

M: another-computer <game-loop>
    computer pairs:<pair> <game-loop> ;

M: algo-random my-turn
    drop { 1 2 } random inc-score drop ;

! if both are high or both are low, the second player always wins
! where high and low are always-1 always-2 algorithms
! if player 1 is high and 2 is low, 1 wins
! if player 1 is low and 2 is high, 1 wins
M: computer         take-turn algo-random my-turn ; ! player 1
M: another-computer take-turn algo-random my-turn ; ! player 2

M: another-computer win
    says another-win print ;

M: another-computer play-21
    21-game ;

: play-21-botwars ( -- ) another-computer play-21 ;
MAIN: play-21-botwars
