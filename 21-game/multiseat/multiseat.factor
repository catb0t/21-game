USING: 21-game 21-game.private arrays io kernel pairs ;
IN: 21-game.multiseat

CONSTANT: another-you-intro "\t<Another You>: "
CONSTANT: another-prompt-text "Another 1 or 2? "
CONSTANT: another-win "I win, you lose!"

SINGLETONS: another-you ;

INSTANCE: another-you player

M: another-you says
    drop another-you-intro writefl ;

M: another-you human-prompt
    drop another-prompt-text writefl ;

M: another-you <21-base-game>
    you 2array <21-base-game> ;

M: another-you <game-loop>
    you pairs:<pair> <game-loop> ;

M: another-you take-turn
    your-turn ;

M: another-you win
    says another-win print ;

M: another-you play-21
    21-game ;

: play-21-against-another ( -- ) another-you play-21 ;
MAIN: play-21-against-another
