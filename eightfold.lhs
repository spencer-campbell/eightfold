# Eightfold: Chaos Checkers

A massively multiplayer recursively self-complicating board game based on Ethereum.

Play takes place on an 8x8 board of square tiles.

> data Board = Board [[Tile]]

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
>   { position :: Position
    , level :: Level
>   , player :: PlayerID
>   }

A force may be placed in any unoccupied tile. If a new force is placed in a tile on the same turn that an existing force moves into it, the placement fails, refunding ether. If two or more players place forces in the same tile on the same turn, the tile becomes contested.

> data Tile
>   = Unoccupied
>   | Occupied Force
>   | Contested Board
