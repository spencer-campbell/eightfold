> import Data.Array (Array, array, elems, (!))
> import Data.List (nub)
> import Data.Maybe (mapMaybe)

*Eightfold: Chaos Checkers*

A massively multiplayer recursively self-complicating board game based on Ethereum.

Play takes place on an 8x8 board of square tiles.

> type Board = Array Position Tile
> type Position = (Char,Int)
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
>   { level :: Level
>   , player :: PlayerID
>   }
> type Level = Int
> type PlayerID = Int

A force may be placed in any unoccupied tile. If a new force is placed in a tile on the same turn that an existing force moves into it, the placement fails, refunding ether. If two or more players place forces in the same tile on the same turn, the tile becomes contested.

> data Tile
>   = Unoccupied
>   | Occupied Force
>   | Contested Board

A contested tile contains an inner 8x8 board of square tiles. The tile remains contested as long as forces owned by two or more players occupy tiles within it.

> viewTile :: Board -> Position -> Maybe (Either Force Board)
> viewTile b p = case b!p of
>   Unoccupied -> Nothing
>   Occupied f -> Just $ Left f
>   Contested b' -> Just $ Right b

When a tile is no longer contested, the forces in it join together into a single force occupying the previously contested tile.

> resolveContest :: Board -> Tile
> resolveContest b
>   | length (playersIn b) >= 2 = Contested b
>   | length (playersIn b) == 1 = Occupied $ Force {level = totalForces b, player = head $ playersIn b}
>   | otherwise = Unoccupied
>
> totalForces :: Board -> Level
> totalForces = sum . mapMaybe getForce . elems
>
> getForce :: Tile -> Maybe Level
> getForce Unoccupied = Nothing
> getForce (Occupied f) = Just $ level f
> getForce (Contested b) = Just $ totalForces b
>
> playersIn :: Board -> [PlayerID]
> playersIn = nub . (getPlayers =<<) . elems
>
> getPlayers :: Tile -> [PlayerID]
> getPlayers Unoccupied = []
> getPlayers (Occupied f) = [player f]
> getPlayers (Contested b) = playersIn b
