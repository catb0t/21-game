USING: 21-game 21-game.private accessors io kernel ;
IN: 21-game.clever

SINGLETONS: algo-clever ;

M: algo-clever my-turn
    2drop 20 >>current
    computer-says "20!" print ;

M: computer take-turn
    algo-clever my-turn ;

MAIN: play-21-against-computer
