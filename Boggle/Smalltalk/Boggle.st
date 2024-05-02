Object subclass: #Boggle
	instanceVariableNames: ''
	classVariableNames: ''
	package: ''!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Boggle class
	instanceVariableNames: ''!

"Class-side method of the Boggle class that validates if a given row and column position is within the bounds of the Boggle game board
This method is necessary for ensuring that the search algorithm does not try to access positions that are outside or not on the board (if it does, then it is an error).
Variables: 
row --> The row position being checked.
col --> The column position being checked.
boggleBoard --> A 2D collection representing the game board, where each element is a row in the board.
This method returns a Boolean value indicating whether the given row and col are within the valid range of the boggleBoard's dimensions."

positionConfirmation: row col: col in: boggleBoard

	 "numRows --> A local variable to store the number of rows in the Boggle game board
	  numCols --> A local variable to store the number of columns in the Boggle game board"
    | numRows numCols |

	 "Assign the total number of rows in the Boggle game board to numRows."
    numRows := boggleBoard size.

	 "If the board is empty (contains no rows), then return false since any position would be invalid."
    numRows = 0 ifTrue: [^false]. 

    "Assign the number of columns in the 1st row of the Boggle game board to numCols.
    This assumes an evenly organized game board where all rows have the same number of columns."
    numCols := (boggleBoard at: 1) size.

	"Returns the result of checking whether row and col are inside the valid range.
   Checks whether a row is within 1 and numRows and whether a col is within 1 and numCols using between:and:.
   Combines this with and: to ensure both conditions are met for the method to return true."
   ^(row between: 1 and: numRows) and: [col between: 1 and: numCols].
! !

"Class-side method of the Boggle class used to calculate a new position based on a given row and column with provided offsets 
This method applying row and column offsets to a current position, which is useful for exploring adjacent cells on the Boggle game board.
During the search process, this calculation is used to determine potential next steps from a given cell.
Variables: 
row --> The current row index of the position
col --> The current column index of the position
dr --> The offset to be applied to the row index. This offset could be -1, 0, or 1, representing a move up, no move, or a move down, respectively.
dc --> The offset to be applied to the column index. Similar to dr, this offset could be -1, 0, or 1, indicating a move left, no move, or a move right.
This method returns a point object representing the new position after applying the row and column offsets."

calculateRowOffsetPosition: row col: col withRowOffset: dr colOffset: dc

	 "nextRow --> Stores the new caluclated row position
	  nextCol --> Stores the new calculated column position"
    | nextRow nextCol |

	 "Calculate the new row position by adding the row offset (dr) to the current row index." 
    nextRow := row + dr.

	 "Calculate the new column position by adding the column offset (dc) to the current column index."
    nextCol := col + dc.

	 "Return a Point object representing the new position. 
	 '@' --> Used to create a Point object from two integers." 
    ^nextRow @ nextCol.! !

"A class-side method of the Boggle class that initiates a search for a given word within the Boggle game board
The recursive search algorithm, which looks for the word starting from any position on the board, uses this method as a starting point
Variables:
word --> The word to search for on the Boggle game board.
boggleBoard --> The game board, a 2D collection where each element corresponds to a cell on the board.
This method returns an OrderedCollection representing the path (sequence of positions) where the word is found on the game board, or nil if the word cannot be found on the game board."

findWordOnGameBoard: word in: boggleBoard 
	 
	 "size --> Stores the size of the game board"
	 | size |
	
	 "Assigns the number of rows in boggleBoard (game board) to size. 
	 This assumes a square board where the number of rows equals the number of columns."
    size := boggleBoard size.

	 "Iterate over each row of the boggleBoard from 1 to the size of the game board."
    1 to: size do: [:row |
	 		
		  "Nested iteration over each column of the boggleBoard for the current row, effectively iterating over            every cell."
        1 to: size do: [:col |
				
				 "Tries to find the word starting from the current cell (row@col) using the recursive search 				               method. 
				 The search starts at index 1 of the word and follows an empty path (OrderedCollection new) to 				 				 track the positions of the found letters."
            (self findWordOnGameBoardRecursive: word atIndex: 1 in: boggleBoard startingAt: row@col withPath: OrderedCollection new) ifNotNil: [:path |
					 "If the word is found,  return the path where the word was found.
					 If the word is not found, then return nil."
                ^path]]].
    "Return nil if the word cannot be located beginning in any cell on the board. This indicates that there was 	 no success in the search "
    ^nil.

! !


"Class-side method of Boggle Class that searches the Boggle game board for a given list of legal words (given as array of strings. It returns a dictionary where each key is a found word on the game board, and the value is an array of the found word's positions on the game board
Variables: 
boggleBoard --> The game board to be searched.
words --> An array of strings representing the words to search for." 
search: boggleBoard for: words
	
	"searchedWords --> A local variable to store words that are found on the game board and their positions"
	| searchedWords |
	
	"Initialize searchedWords as a new dictionary (The method should return a dictionary).
	This will hold each found word as a key, with the corresponding value being an array of positions of that 		 	word on the game board."
   searchedWords := Dictionary new.

	"Iterate over each word in the provided array of strings representing the list of words using a block.
	This loop checks each word on the Boggle game board to determine whether it can be found or not."
   words do: [:word |
		 "Call and use the wordSearch:in: method to search for the word that is currently on the game board.
		 If the word is found, save the positions of the word (otherwise, wordSearch:in: returns nil)"
       (self findWordOnGameBoard: word in: boggleBoard) ifNotNil: [:positions |
				"Add the discovered word in the dictionary created in the method along with its positions. 
				For consistent data handling, positions are saved as an array."
				"asArray --> used to convert a collection (set, list, dictionary) into an array."
				searchedWords at: word put: positions asArray]].

	"After all words have been searched, return the dictionary containing the search results (all found words   	and their positions on the board)."
   ^searchedWords.
	

						
						
! !

"Class-side method of Boggle class generates a collection of next possible positions on a Boggle game board from a given starting position, excluding a specified position and ensuring all possible positions are inside the board's bounds 
Variables: 
row --> The row index of the current position
col --> The column index of the current position
excludedPosition --> A position to be excluded from the resulting collection, typically the current position to prevent revisiting
boggleBoard --> The game board, a 2D collection where each element represents a cell on the board."

rowNextPositions: row col: col excluding: excludedPosition in: boggleBoard

	 "nextPositions --> stores the resulting collection of valid next positions."
    | nextPositions |
    
    "Initialize nextPositions as a new OrderedCollection to maintain the order of insertion."
    nextPositions := OrderedCollection new.

	 "Iterate over row offsets (-1, 0, 1) to explore positions above, at, and below the current row."
    -1 to: 1 do: [:dr |
	
		 "Iterate over column offsets (-1, 0, 1) to explore positions left, at, and right of the current column."
        -1 to: 1 do: [:dc |
	
			   "nextPos --> Stores the next position being considered"
            | nextPos |

				"Calculate the next position based on the current position and the offsets using a helper method."
            "This method adjusts the current position by dr and dc to find adjacent positions."
            nextPos := self calculateRowOffsetPosition: row col: col withRowOffset: dr colOffset: dc.
            
				"Use another helper method to check if the calculated position is valid 
				(i.e., within board bounds and not the excluded position).
            If valid, the position is added to nextPositions. Otherwise, it's ignored."
            self addPositionIfValid: nextPos toCollection: nextPositions excluding: excludedPosition in: boggleBoard
        ]
    ].

    "After evaluating all possible adjacent positions, return the collection of valid next positions."
    ^nextPositions.! !

"A recursive class-side method of the Boggle class that searches the Boggle game board for a given word on the starting from a specific position
This method is called recursively to move across adjacent positions on the game board to build the word.
Variables: 
word --> The target word to search for on the game board.
index --> The current index in the word that the search is attempting to match on the game board.
boggleBoard --> A 2D collection representing the Boggle game board, with each cell containing a letter.
start --> The current starting position on the board for this step of the search, represented as a Point (row@col).
path --> An OrderedCollection tracking the sequence of positions visited during the current search path.
This method returns an OrderedCollection representing the path of positions that spell out the word if found. Otherwise, it returns nil."

findWordOnGameBoardRecursive: word atIndex: index in: boggleBoard startingAt: start withPath: path

	 "row --> Stores the row of the current starting position 
	  col --> Stores the column of the current starting position 
	  nextPositions --> Stores a collection of potential next positions that the search algorithm can move to from the current position (start) on the boggle board.
	  newPath --> Stores an OrderedCollection representing the current path taken to find a word on the Boggle game board.  "
    | row col nextPositions newPath |

	 "Extracts the row from the starting position"
    row := start x.

	 "Extracts the column from the starting position"
    col := start y.

	 "Check if the current position is valid within the board dimensions. If not, return nil to indicate failure at this path."
    (self positionConfirmation: row col: col in: boggleBoard) ifFalse: [^nil].

    "Check if the current position has already been visited in this search path to avoid cycles. If so, return nil."
    (self isPositionVisited: start inPath: path) ifTrue: [^nil].

	 "Check if the letter at the current board position matches the current letter of the word being searched. If not, return nil.
	 '~=' --> Checks inequality between 2 objects. Returns true if the objects aren't equal and false if they are equal. Opposite of '='."
    ((boggleBoard at: row) at: col) ~= (word at: index) ifTrue: [^nil].

    "Copy the current path and add the current position to it, creating a new path for this recursion depth."
    newPath := path copy.
    newPath add: start.

	  "Check if the complete word has been found by comparing the current index with the word's length. If so, return the path."
    (self isCompleteWord: word atIndex: index) ifTrue: [^newPath].

	  "Generate the next possible positions to move from the current one, excluding the current position to prevent revisiting."
    nextPositions := self rowNextPositions: row col: col excluding: start in: boggleBoard.

	 "Iterate over each possible next position."
    nextPositions do: [:nextPos |
		
		 "nextRow --> Extracts the row from the next position.
		  nextCol --> Extracts the column from the next position."
        | nextRow nextCol |
        nextRow := nextPos x.
        nextCol := nextPos y.

		  "Confirm the next position is valid before proceeding with the recursive search from that position."
        (self positionConfirmation: nextRow col: nextCol in: boggleBoard) ifTrue: [
	
				"Recursively call this method with the next position and the updated path. If a valid path is found, return it."
            (self findWordOnGameBoardRecursive: word atIndex: index + 1 in: boggleBoard startingAt: nextPos withPath: newPath) ifNotNil: [:resultPath |
                ^resultPath]]].

	 "If no valid path is found from any of the next positions, return nil to indicate failure to find the word from this starting position."
    ^nil.! !


"Class-side method of Boggle Class that determines whether a suggested next position on the Boggle game board is valid for continuing on with the search process 
A position is deemed valid if it does not match a specified excluded position (to prevent revisiting the same cell) and if it is inside the valid boundaries of the Boggle game board. By avoiding invalid moves and following the game's rules, this method is essential for maintaining the integrity of the search process. 
Variables: 
nextPos --> The position being considered as the next step in the search, represented as a Point object conisting of x (row) and y (column) coordinates.
excludedPosition --> A position that the search algorithm aims to avoid, usually the current or previously visited position, to prevent cycles or unnecessary exploration
boggleBoard --> The game board, a 2D collection where each element represents a cell on the board.
This method returns a Boolean value indicating whether nextPos is a valid position to move to in the search process."

isValidNextPosition: nextPos excluding: excludedPosition in: boggleBoard
	 "Evaluates and returns true if the next position (nextPos) is not equal to the excluded position and            within the boundaries of the Boggle game board. 
	 '~=' --> Used to check for inequality, ensuring the next position isn't the excluded one. 
	 The helper method below checks the next position's validity within the board's limits. 
    Both conditions must be met for the method to return true, meaning the next position is valid for the           search."
    ^(nextPos ~= excludedPosition) and: [self positionConfirmation: nextPos x col: nextPos y in: boggleBoard].! !

"Class-side method of the Boggle class that determines whether a given position has already been visited in the current search path 
This essential method ensures that the search does not revisit the same cell on the Boggle game board.
Variables:
position --> The position (represented as a Point object) being checked.
path --> An OrderedCollection of previously visited positions.
This method returns a Boolean value indicating True (the position has already been visited) or False (the position has already been visited)."

isPositionVisited: position inPath: path	

   "anySatsify: --> used to check if any elment in a collection satisfies a given condition. 
	Iterates over each visited position in the path using anySatisfy:. 
	It checks that if each visited position is equal to the position being inquired about
	'=' --> Used for comparison, which should be defined for the type of objects stored in path to correctly     	compare them.  
	True is returned if any visited position matches the position that is being inquired about (meaning the    	position has been (visited). 
	False is returned if no matches are found after checking all visited positions (meaning the position has not    been visited.
	The result of whether the position has been visited is returned"
	^path anySatisfy: [:visitPos | visitPos = position].! !

"Class-side method of Boggle class that determines whether the given index matches the completion of the word
This method is useful in recursive search operations to determine if a complete word has been found based on the current index in the recursion.
Variables: 
word --> The word that is being searched for in the Boggle game board.
index --> The current index in the word being checked. This index is compared against the total length of the word to determine the completion of the world.
This method returns a Boolean value. It returns True if the current index equals to the size of the word, indicating that the entire word has been traversed and found. Otherwise, it returns false. "

isCompleteWord: word atIndex: index
    
	"Compares the word size with the given index. In the event that they are equal, it indicates that the search 	     has reached the end of the word, meaning the word is complete.
    '=' --> A comparison that checks for equality between the index and the length of the word.
    The method's result is directly returned as the outcome of this comparison." 
	^index = word size.! !


"Class-side method of Boggle class that adds a position to a collection of positions if it meets certain requirements
Before adding the given position to the designated collection, it verifies that it is valid (not the excluded position and inside the bounds of the Boggle game board). 
This method is used to filter and accumulate valid next positions during the search process on the Boggle game board.
Variables: 
nextPos --> The position being considered for addition
nextPositions --> An OrderedCollection where valid next positions are accumulated.
excludedPosition --> A specific position that is intentionally excluded from being added to nextPositions (Typically, this is the current position in the search path, excluded to prevent the algorithm from going back to the same cell in its immediate next step, helping in avoiding loops or unnecessary paths in the search process).
boggleBoard --> The Boggle game board, a 2D collection where each element represents a cell on the board."

addPositionIfValid: nextPos toCollection: nextPositions excluding: excludedPosition in: boggleBoard

	 "Check if nextPos is a valid next position by calling the helper method below.
    This check involves ensuring nextPos is not the same as the excludedPosition and that it falls within 
    the valid bounds of the boggleBoard."
    (self isValidNextPosition: nextPos excluding: excludedPosition in: boggleBoard) ifTrue: [
	
		  "Add nextPos to the OrderedCollection nextPositions if the position is valid based on the conditions   		         verified.  In order to ensure that only valid next steps are taken into account by the search 		            algorithm, this step accumulates nextPos into nextPositions (only if it passes the validity checks)."
        nextPositions add: nextPos
    ].! !
