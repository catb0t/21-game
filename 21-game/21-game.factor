USING: calendar combinators formatting hashtables io kernel math math.parser
prettyprint random namespaces sequences sequences.interleaved threads ;
IN: 21-game

CONSTANT: player-prompt-text "Add 1 or 2? "
CONSTANT: i-lose "I lose? It's impossible!"
CONSTANT: you-lose "You lose! Numbers are my domain!"
CONSTANT: max-turns-to-21 11

SINGLETONS: computer you next,play next,skip next,announce algo-lose algo-random algo-cheat ;
MIXIN: next, INSTANCE: next,announce next, INSTANCE: next,skip next,

: writefl ( str -- ) write flush ;
: 21? ( number -- 21? ) 21 >= ;
: computer-says ( -- ) "\t<Computer>: " writefl ;
: you-say ( -- ) "\t<You>: " writefl ;
: slow-dots ( -- ) "..." [ 1/5 seconds sleep "%c" printf flush ] each 1/2 seconds sleep ;
: your-prompt ( -- n )
    player-prompt-text writefl readln string>number
    dup { 1 2 } [ = ] with any? [ drop your-prompt ] unless ;

: your-turn ( n -- n ) your-prompt + dup you-say { "!" "." } random "%d%s\n" printf flush ;

GENERIC: my-turn ( n who -- n )
M: algo-lose my-turn   drop 2 + dup computer-says "%d." printf flush nl ;
M: algo-cheat my-turn 2drop 20 computer-says "20!" print ;
M: algo-random my-turn
    drop { 1 2 } random [ + ] keep over computer-says slow-dots
    "%d, " printf flush 3/4 seconds sleep "I guess. " writefl 3/4 seconds sleep "(%d)" printf flush nl ;

GENERIC: take-turn ( n who -- n )
M: computer take-turn drop algo-random my-turn ;
M: you take-turn drop your-turn ;

GENERIC: win ( who -- )
M: computer win drop computer-says you-lose print ;
M: you win drop computer-says i-lose print ;

GENERIC: play-21 ( against -- )
M: you play-21 drop computer-says "You can't play against yourself!" print ;
M: computer play-21
    drop "0." print 0 max-turns-to-21 you <repetition> computer <interleaved>
    [ over next,? [ over next,announce? [ win drop ] [ 2drop ] if next,skip ]
        [ take-turn dup 21? [ drop next,announce ] when ] if
    ] each drop ;

: play-21-against-computer ( -- ) computer play-21 ;
MAIN: play-21-against-computer
