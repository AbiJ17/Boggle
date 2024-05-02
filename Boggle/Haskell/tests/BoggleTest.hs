module Main where
    import Test.HUnit
    import Data.Set (Set)
    import Data.List
    import Data.Array.IO
    import System.Random
    import Control.Monad
    import Data.Char (isSpace)
    import Data.Time.Clock.POSIX (getPOSIXTime)
    import Data.Char (isSpace)
    import Data.Time
    import qualified Boggle
    import qualified Data.Set as Set
    import qualified System.Exit as Exit

    main = do
        results <- runTestTT tests
        print results

    -- run tests with:
    --     cabal test

    boggle = Boggle.boggle
    wordsLegal :: [(String, [(Int, Int)])] -> [String] -> Bool
    wordsLegal found words =
        let wordSet = Set.fromList words
        in all (\(word, _) -> Set.member word wordSet) found

    wordsInBoard :: [ (String, [ (Int, Int) ] ) ] -> [[Char]] -> Bool
    wordsInBoard found board = 
        let res = map (\entry -> validateWord board entry) found 
        in  foldl (&&) True res

    wordCoordsOK found board =
        let res = map (\entry -> validateCoords entry) found 
        in  foldl (&&) True res

    validateWord :: [[Char]] -> ( [Char], [ (Int, Int) ] ) -> Bool
    validateWord board (word, coords) = 
        let zipped = zip word coords 
            res = map (\(ch, (x, y)) -> ch == (getCell board x y)) zipped
        in  foldl (&&) True res
        
    validateCoords (_, coords) = 
        let dup = length coords == Set.size (Set.fromList coords)
            xc = [ x | (x, _) <- coords ]
            x_ok = foldl (&&) True $ map (\(x1, x2) -> abs (x1-x2) <= 1) $ (zip xc $ tail xc) 
            yc = [ y | (_, y) <- coords ]
            y_ok = foldl (&&) True $ map (\(y1, y2) -> abs (y1-y2) <= 1) $ (zip yc $ tail yc) 
        in  dup && x_ok && y_ok

    getCell :: [[Char]] -> Int -> Int -> Char
    getCell board x y = (board !! x) !! y

    -- Calculates the score based on word lengths
    getScore :: [(String, [(Int, Int)])] -> Int
    getScore found =
        let wScores = [1, 2, 4, 6, 9, 12, 16, 20]
        in sum [if length w <= 8 then wScores !! (length w - 1) else 20 | (w, _) <- found]

    -- Shuffles a list in a random order
    shuffle :: [a] -> IO [a]
    shuffle xs = foldM removeRandom [] xs
        where removeRandom acc _ = do
                index <- getStdRandom $ randomR (0, length xs - 1)
                return $ (xs !! index) : acc

    -- Removes leading and trailing whitespace from a string
    trim :: String -> String
    trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace
    
    tests :: Test
    tests = TestList [
        TestLabel "Test Basic Functionality on a 2x2 Board" testBasic2x2,
        TestLabel "Test All Directions on a 4x4 Board" testAllDirections4x4,
        TestLabel "Test Large Board 8x8" testEmbedded8x8Board,
        TestLabel "Test Massive Board 16x16" testEmbedded16x16Board, 
        TestLabel "Test Find Words on Board" testFindWordsOnBoard, 
        TestLabel "Test Backtracking and Overlapping" testBacktrackingAndOverlapping, 
        TestLabel "Test Diagonal Words" testDiagonalWordsOnBoard, 
        TestLabel "Test Overlapping Words" testHandlesOverlappingWords, 
        TestLabel "Test Find Words on 2x2 Board" testFindsWordsOn2x2Board
        ]

    testBasic2x2 :: Test
    testBasic2x2 = TestCase $ do
        let board = ["ea", "st"]
            words = ["eat", "tea", "ate"]
            found = boggle board words
            legalWords = wordsLegal found words
            inBoard = wordsInBoard found board
            coordsOK = wordCoordsOK found board
            score = getScore found
        assertBool "Check if all found words are legal" legalWords
        assertBool "Check if all words fit on the board" inBoard
        assertBool "Check if word coordinates are valid" coordsOK
        assertEqual "Check the scoring of found words" expectedScore score
        where expectedScore = 12  -- Assuming each word scores 4

    testAllDirections4x4 :: Test
    testAllDirections4x4 = TestCase $ do
        let board = ["soup", "rope", "abnd", "nerd"]
            words = ["soup", "rope", "nerd", "den", "open", "pen"]
            found = boggle board words
            legalWords = wordsLegal found words
            inBoard = wordsInBoard found board
            coordsOK = wordCoordsOK found board
            score = getScore found
            expectedScore = calculateExpectedScore ["soup", "rope", "nerd", "den"]

        -- Perform assertions to validate the conditions
        assertBool "Check if all found words are legal" legalWords
        assertBool "Check if all words fit on the board" inBoard
        assertBool "Check if word coordinates are valid" coordsOK
        assertEqual "Check the scoring of found words" expectedScore score
    
    testEmbedded8x8Board :: Test
    testEmbedded8x8Board = TestCase $ do
        let board = [
                "connecri", "oleaders", "nnetwork", "programming",
                "algorithm", "functions", "variable", "constants"
                ]
            words = ["connection", "leadership", "network", "programming", "algorithm",
                    "function", "variable", "constant", "binary", "framework"]
            found = boggle board words
            legalWords = wordsLegal found words
            inBoard = wordsInBoard found board
            coordsOK = wordCoordsOK found board
            score = getScore found
            expectedScore = calculateExpectedScore ["connection", "network", "algorithm", "variable"]

        assertBool "Check if all found words are legal" legalWords
        assertBool "Check if all words fit on the 8x8 board" inBoard
        assertBool "Check if word coordinates are valid on 8x8 board" coordsOK
        assertEqual "Check the scoring of found words on 8x8 board" expectedScore score

    testEmbedded16x16Board :: Test
    testEmbedded16x16Board = TestCase $ do
        let board = [
                "configuration", "establishment", "microprocessor", "telecommunication",
                "infrastructure", "superintendent", "multidimensional", "decentralization",
                "intercontinental", "philanthropist", "misinterpretation", "technologically",
                "incompatibilities", "disproportionate", "anthropological", "counterproductive"
                ]
            words = ["configuration", "establishment", "microprocessor", "telecommunication",
                    "infrastructure", "superintendent", "multidimensional", "decentralization",
                    "intercontinental", "philanthropist", "misinterpretation", "technologically",
                    "incompatibilities", "disproportionate", "anthropological", "counterproductive"]
            found = boggle board words
            legalWords = wordsLegal found words
            inBoard = wordsInBoard found board
            coordsOK = wordCoordsOK found board
            score = getScore found
            expectedScore = calculateExpectedScore ["configuration", "telecommunication", "multidimensional"]

        assertBool "Check if all found words are legal on 16x16 board" legalWords
        assertBool "Check if all words fit on the 16x16 board" inBoard
        assertBool "Check if word coordinates are valid on 16x16 board" coordsOK
        assertEqual "Check the scoring of found words on 16x16 board" expectedScore score

    testFindWordsOnBoard :: Test
    testFindWordsOnBoard = TestCase $ do
        let board = ["cat", "bta", "dek"]
            words = ["cat", "bet"]
            found = boggle board words
            expected = [("bet", [(1, 0), (2, 1), (1, 1)]), ("cat", [(0, 0), (0, 1), (1, 1)])]
        assertBool "finds diagonal words on a board" (wordsInBoard found board && wordsLegal found words)

    testBacktrackingAndOverlapping :: Test
    testBacktrackingAndOverlapping = TestCase $ do
        let board = ["star", "urms", "tart", "stun"]
            words = ["start", "stun", "tart", "rum"]
            found = boggle board words
            expected = [("start", [(0, 0), (0, 1), (0, 2), (1, 1), (2, 0)]),
                        ("stun", [(3, 0), (3, 1), (3, 2), (3, 3)]),
                        ("tart", [(2, 0), (2, 1), (2, 2), (2, 3)])]
        assertBool "recognizes words requiring backtracking" (wordsInBoard found board && wordsLegal found words)

    testDiagonalWordsOnBoard :: Test
    testDiagonalWordsOnBoard = TestCase $ do
        let board = ["cat", "bta", "dek"]
            words = ["cat", "bet"]
            found = boggle board words
            expected = [("bet", [(1, 0), (2, 1), (1, 1)]), ("cat", [(0, 0), (0, 1), (1, 1)])]
        assertBool "Diagonal and horizontal words test" (expected == found)

    testHandlesOverlappingWords :: Test
    testHandlesOverlappingWords = TestCase $ do
        let board = ["sos", "oat", "mom"]
            words = ["so", "sat", "mom"]
            found = boggle board words
            expected = [("mom", [(2, 0), (2, 1), (2, 2)]),
                        ("sat", [(0, 2), (1, 1), (1, 2)]),
                        ("so", [(0, 2), (0, 1)])]
        assertBool "Overlapping words test" (expected == found)

    testFindsWordsOn2x2Board :: Test
    testFindsWordsOn2x2Board = TestCase $ do
        let board = ["ab", "ba"]
            words = ["ab", "ba"]
            found = boggle board words
            expected = [("ab", [(0, 0), (0, 1)]), 
                        ("ba", [(1, 0), (1, 1)])]
        assertBool "2x2 board words test" (expected == found)

    -- Function to calculate the expected score based on a list of words
    calculateExpectedScore :: [String] -> Int
    calculateExpectedScore words = 
        let w_scores = [1, 2, 4, 6, 9, 12, 16, 20]
            scores = map (\w -> if length w <= 8 then w_scores !! (length w - 1) else 20) words
        in sum scores