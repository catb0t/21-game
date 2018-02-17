USING: accessors arrays assocs calendar combinators formatting
formatting.private fry generalizations hashtables io kernel locals
macros math math.parser namespaces prettyprint random sequences strings
sequences.interleaved threads ;
QUALIFIED: pairs
IN: 21-game

CONSTANT: computer-intro "\t<Computer>: "
CONSTANT: you-intro "\t<You>: "
CONSTANT: player1-prompt-text "Add 1 or 2? "
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
    { current    integer    initial: 0 }
    { next-time  next       initial: play }
    { turn-hists hashtable  initial: H{ } } ;

<PRIVATE
: writefl ( str -- ) write flush ;
MACRO: printfl ( format-string -- quot )
    printf-quot
    [ [ output-stream get [ stream-write ] curry ] compose ] dip
    [ napply flush ] curry compose ;

: sleep-sec ( sec -- ) seconds sleep ;

: read-you ( -- something )
    readln dup "q" = [ drop f ] when ;

: 21? ( game -- 21? ) current>> 21 >= ;

: slow-dots ( -- ) "..." [ 1/5 sleep-sec "%c" printfl ] each 1/2 sleep-sec ;

PRIVATE>

GENERIC: human-prompt ( player -- )
M: you human-prompt
    drop player1-prompt-text writefl ;

GENERIC: says ( who -- )
M: computer says
    drop computer-intro writefl ;
M: you says
    drop you-intro writefl ;

GENERIC: <21-base-game> ( desc -- new-game )
M: pair <21-base-game>
    [ { } 2array ] map >hashtable
    [ 21-base-game new ] dip >>turn-hists ;

M: computer <21-base-game>
    you 2array <21-base-game> ;

GENERIC: <game-loop> ( desc -- ticker )
M: pairs:pair <game-loop>
    [ key>> [ max-turns-to-21 ] dip <repetition> ]
    [ value>> ] bi <interleaved> ;

M: computer <game-loop>
    you pairs:<pair> <game-loop> ;

: play-next? ( game -- ? )     next-time>> play? ;
: announce-next? ( game -- ? ) next-time>> announce? ;
: skip-next? ( game -- ? )     next-time>> skip? ;

: announce-next ( game -- game ) announce >>next-time ;
: skip-next ( game -- game )         skip >>next-time ;

: record-turn ( game who add -- )
    swapd [ turn-hists>> ] dip '[ _ suffix ] change-at ;

: inc-score ( game who add -- game+ new )
    dup skip? [
        2drop skip-next "I quit"
    ] [
        [ record-turn ]
        [ nip '[ _ + ] change-current drop ]
        [ 2drop dup current>> ] 3tri
    ] if ;

:: your-prompt ( who -- n )
    who human-prompt read-you [
        string>number dup { 1 2 } member? [ drop who your-prompt ] unless
    ] [ skip ] if* ;

: your-turn ( game who -- game )
    [ dup your-prompt [ inc-score ] keep drop ] keep says
    { "!" "." } random "%s%s\n" printfl ;

GENERIC: my-turn ( game who algo -- game )
M: algo-lose my-turn
    drop [ 2 inc-score ] keep
    says "%d.\n" printfl ;

M: algo-cheat my-turn
    2drop 20 >>current
    computer says "20!" print ;

M: algo-random my-turn
    drop [ { 1 2 } random [ inc-score ] keep swap ] keep
    says slow-dots
    "%d, "      printfl 3/4 sleep-sec
    "I guess. " writefl 1/4 sleep-sec
    "(%d)\n"    printfl ;

GENERIC: take-turn ( game who -- game )
M: computer take-turn
    algo-random my-turn ;
M: you take-turn
    your-turn ;

GENERIC: win ( game who -- game )
M: computer win
    says you-lose print ;
M: you win
    drop computer says i-lose print ;

: 21-game ( against -- )
    "q to quit" print

    [ <21-base-game> ]
    [ <game-loop> ] bi ! TODO: make these parameters?

    [ over play-next? [
            take-turn dup 21? [ announce-next ] when
        ] [
            over announce-next? [ win skip-next ] [ drop ] if
        ] if
    ] each drop ;

GENERIC: play-21 ( against -- )
M: you play-21
    drop computer says "You can't play against yourself!" print ;

M: computer play-21
    21-game ;

: play-21-against-computer ( -- ) computer play-21 ;
MAIN: play-21-against-computer
