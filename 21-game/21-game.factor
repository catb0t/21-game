USING: accessors arrays calendar combinators formatting
hashtables io kernel math math.parser namespaces prettyprint
random sequences sequences.interleaved threads ;
IN: 21-game

CONSTANT: player-prompt-text "Add 1 or 2? "
CONSTANT: i-lose "I lose? It's impossible!"
CONSTANT: you-lose "You lose! Numbers are my domain!"
CONSTANT: max-turns-to-21 11

SINGLETONS: computer you play skip announce algo-lose algo-random algo-cheat ;

MIXIN: next
INSTANCE: play next
INSTANCE: announce next
INSTANCE: skip next

MIXIN: player
INSTANCE: you player
INSTANCE: computer player

TUPLE: 21-base-game
    { current integer initial: 0 }
    { iteration integer initial: 0 }
    { next-time next initial: play }
    { turns-so-far hashtable initial: H{ } }
    { last-turn-owner player initial: you } ;

: writefl ( str -- ) write flush ;

: 21? ( game -- 21? ) current>> 21 >= ;

: computer-says ( -- ) "\t<Computer>: " writefl ;
: you-say ( -- ) "\t<You>: " writefl ;

: slow-dots ( -- ) "..." [ 1/5 seconds sleep "%c" printf flush ] each 1/2 seconds sleep ;

: <21-base-game> ( players -- new-game )
    [ { } 2array ] map >hashtable
    [ 21-base-game new ] dip >>turns-so-far ;

: play-next? ( game -- ? )
    next-time>> play? ;
: announce-next? ( game -- ? )
    next-time>> announce? ;
: skip-next? ( game -- ? )
    next-time>> skip? ;

: inc-game ( n game -- game )
    [ current>> + ] keep swap >>current ;

: your-prompt ( -- n )
    player-prompt-text writefl readln string>number
    dup { 1 2 } [ = ] with any? [ drop your-prompt ] unless ;

: your-turn ( game -- game ) your-prompt inc-game dup you-say { "!" "." } random "%d%s\n" printf flush ;

GENERIC: my-turn ( game who -- game )
M: algo-lose my-turn  drop 2 inc-game dup computer-says "%d." printf flush nl ;
M: algo-cheat my-turn drop 20 >>current computer-says "20!" print ;
M: algo-random my-turn
    drop { 1 2 } random [ + ] keep over computer-says slow-dots
    "%d, " printf flush 3/4 seconds sleep "I guess. " writefl 3/4 seconds sleep "(%d)" printf flush nl ;

GENERIC: take-turn ( game who -- game )
M: computer take-turn drop algo-random my-turn ;
M: you take-turn drop your-turn ;

GENERIC: win ( game who -- game )
M: computer win drop computer-says you-lose print ;
M: you win drop computer-says i-lose print ;

GENERIC: play-21 ( against -- )
M: you play-21 drop computer-says "You can't play against yourself!" print ;
M: computer play-21
    "0." print
    you
    [ 2array <21-base-game> ]
    [ max-turns-to-21 swap <repetition> swap <interleaved> ] 2bi

    [ over play-next? [
            take-turn dup 21? [ swap announce >>next-time-do ] when
        ] [
            over announce-next? [ win skip >>next-time-do ] [ 2drop ] if
        ] if
    ] each drop ;

: play-21-against-computer ( -- ) computer play-21 ;
MAIN: play-21-against-computer
