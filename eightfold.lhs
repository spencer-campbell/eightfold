> import Data.Array (Array, array, assocs, elems, (!))
> import Data.List (nub)
> import Data.Maybe (fromJust, mapMaybe)

*Eightfold: Chaos Checkers*

A massively multiplayer recursively self-complicating board game based on Ethereum.

Play takes place on an 8x8 board of square tiles.

> type Board = Array Position' Tile
> type Position' = (Char,Int)
>
> emptyBoard :: Board
> emptyBoard = array (('a',1),('h',8)) [ ((x,y),Unoccupied) | x <- ['a'..'h'], y <- [1..8] ]

A player can make one of two moves each turn: place a force or move a force.

> data Move
>   = Place Force AtPosition
>   | Move Force FromPosition ToPosition
>   deriving Eq
> type AtPosition = Position
> type FromPosition = Position
> type ToPosition = Position

A force may be placed into any unoccupied tile. A force which is already on the board may be moved into any tile in its movement pattern.

> validMove :: Board -> PlayerID -> Move -> Bool
> validMove b p (Place f pos) = p == player f && viewTile b pos == Nothing
> validMove b p (Move f pf pt) = p == player f && undefined

All players move simultaneously. 

> play :: Board -> Array PlayerID (Maybe Move) -> Board
> play b ms = makeMoves b [ fromJust mm | (p,mm) <- assocs ms, validMove b p (fromJust mm), mm /= Nothing ]
>
> makeMoves = undefined

Every move costs an amount of ether to play.

> type EtherAmount = Float
>
> moveCost :: Move -> EtherAmount
> moveCost m = undefined

Players join the game by placing a force on the board.

> data Force = Force
>   { level :: Level
>   , player :: PlayerID
>   } deriving Eq
> type Level = Int
> type PlayerID = Int

A force may be placed in any unoccupied tile. If a new force is placed in a tile on the same turn that an existing force moves into it, the placement fails, refunding ether.

If two or more players place forces in the same tile on the same turn, or if two or more players move forces into the same tile on the same turn, the tile becomes contested.

> data Tile
>   = Unoccupied
>   | Occupied Force
>   | Contested Board

When a tile becomes contested, the forces entering it are distributed into an inner 8x8 board of square tiles.

> type Position = [Position']
>
> viewTile :: Board -> Position -> Maybe Force
> viewTile b [] = Nothing
> viewTile b (p:ps) = case b!p of
>   Unoccupied -> Nothing
>   Occupied f -> Just f
>   Contested b' -> viewTile b' ps

The tile remains contested as long as forces owned by two or more players occupy tiles within it. When a tile is no longer contested, the forces in it join together into a single force occupying the previously contested tile.

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
