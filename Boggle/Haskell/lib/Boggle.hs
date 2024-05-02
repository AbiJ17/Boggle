module Boggle (boggle) where

boggle :: [String] -> [String] -> [(String, [(Int, Int)])]
boggle board words =
    let result = [(word, path) |
                    word <- words,
                    let path = findWordOnBoard board word,
                    not (null path)]
    in result

-- Initiate the search for each word on the board.
findWordOnBoard :: [String] -> String -> [(Int, Int)]
findWordOnBoard board word =
    helperLetter board word 0 0 []

helperLetter :: [String] -> String -> Int -> Int -> [(Int, Int)] -> [(Int, Int)]
helperLetter board word x y coords
    | y == length board = []
    | x == length board = helperLetter board word 0 (y + 1) coords
    | otherwise = case adjacentCells board word x y coords of
                    [] -> helperLetter board word (x + 1) y coords
                    path -> path

adjacentCells :: [String] -> String -> Int -> Int -> [(Int, Int)] -> [(Int, Int)]
adjacentCells board word tempx tempy coords
    | isValidPosition board tempx tempy && isCorrectLetter board word tempx tempy && not (alreadyVisited coords tempx tempy) =
        directionChecker board (coords ++ [(tempy, tempx)]) (tail word) (allDirections tempx tempy)
    | otherwise = []

isValidPosition :: [String] -> Int -> Int -> Bool
isValidPosition board x y = x >= 0 && x < length board && y >= 0 && y < length board

isCorrectLetter :: [String] -> String -> Int -> Int -> Bool
isCorrectLetter board word x y = head word == (board !! y) !! x

alreadyVisited :: [(Int, Int)] -> Int -> Int -> Bool
alreadyVisited coords x y = (y, x) `elem` coords

allDirections :: Int -> Int -> [(Int, Int)]
allDirections x y =
    [(x, y + 1), (x, y - 1), (x + 1, y), (x - 1, y),
     (x + 1, y + 1), (x - 1, y + 1), (x + 1, y - 1), (x - 1, y - 1)]

directionChecker :: [String] -> [(Int, Int)] -> String -> [(Int, Int)] -> [(Int, Int)]
directionChecker board coords word directions
    | null word = coords
    | null directions = []
    | otherwise = checkDirection board coords word (head directions) (tail directions)

checkDirection :: [String] -> [(Int, Int)] -> String -> (Int, Int) -> [(Int, Int)] -> [(Int, Int)]
checkDirection board coords word (dx, dy) remainingDirs
    | isValidPosition board dx dy = 
        case adjacentCells board word dx dy coords of
            [] -> directionChecker board coords word remainingDirs
            path -> path
    | otherwise = directionChecker board coords word remainingDirs
