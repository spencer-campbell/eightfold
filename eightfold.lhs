> import Data.Array (Array, array)

*Eightfold: Chaos Checkers*

A massively multiplayer recursively self-complicating board game based on Ethereum.

Play takes place on an 8x8 board of square tiles.

> type Board = Array Position Tile
>
> emptyBoard :: Board
> emptyBoard = array (('a',1),('h',8)) [ ((x,y),Unoccupied) | x <- ['a'..'h'], y <- [1..8] ]

All players move simultaneously. The moves a player can make are: (1) place a force, (2) move a force, and (3) split a force.

> data Move
>   = PlaceForce
>   | MoveForce
>   | SplitForce

Every move costs an amount of ether to play.

> type EtherAmount = Float
>
> moveCost :: Move -> EtherAmount
> moveCost m = undefined

Players join the game by placing a force on the board.

> data Force = Force
>   { position :: Recursive Position
>   , level :: Level
>   , player :: PlayerID
>   }
> type Position = (Char,Int)
> type Level = Int
> type PlayerID = Int

A force may be placed in any unoccupied tile. If a new force is placed in a tile on the same turn that an existing force moves into it, the placement fails, refunding ether. If two or more players place forces in the same tile on the same turn, the tile becomes contested.

> data Tile
>   = Unoccupied
>   | Occupied Level PlayerID
>   | Contested Board

A contested tile contains an inner 8x8 board of square tiles. The tile remains contested as long as forces owned by two or more players occupy tiles within it.

> data Recursive a
>   = Continuing a (Recursive a)
>   | Final a
>
> getForce :: Recursive Position -> Board -> Maybe Force
> getForce = undefined -- TODO: write code to show how recursive positions work

When a tile is no longer contested, the forces in it join together into a single force occupying the previously contested tile.
