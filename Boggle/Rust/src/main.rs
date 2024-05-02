#![allow(non_snake_case,non_camel_case_types,dead_code)]

use std::collections::HashMap;

/*
    Fill in the boggle function below. Use as many helpers as you want.
    Test your code by running 'cargo test' from the tester_rs_simple directory.
    
    To demonstrate how the HashMap can be used to store word/coord associations,
    the function stub below contains two sample words added from the 2x2 board.
*/

// Define a TrieNode structure for efficient prefix and word checking.
struct TrieNode {
    children: HashMap<char, TrieNode>, // Child nodes for each character
    is_word_end: bool, // Flag to indicate if a node completes a word
}

// The main function to find all valid words in a given Boggle board.
fn boggle(board: &[&str], words: &[String]) -> HashMap<String, Vec<(u8, u8)>> {
    let trie = build_trie(words); // Build a trie from the list of words for efficient search
    let mut cellsVisited = vec![vec![false; board[0].len()]; board.len()]; // Track visited cells
    let mut wordsFound = HashMap::new(); // Store found words and their paths
    
    // Iterate over each row of the board, with 'x' being the row index and 'row' the row content.
    board.iter().enumerate().for_each(|(x, row)| {
        // For each character in the row, 'y' is the column index. The character itself is ignored here ('_') 
        // since its value is not directly needed; it will be fetched again during the search.
        row.chars().enumerate().for_each(|(y, _)| {
            // Call the 'search' function for each cell of the board to begin exploring for words from that cell.
            search(
                &trie, // the trie structure containing all valid words.
                board, // current Boggle board being searched
                // convert row and column indices to isize for use with the search function,
                // allowing for the calculation of positions relative to the current cell
                x as isize,
                y as isize,
                String::new(), // starts search with an empty string, as no characters have been accumulated yet.
                // passes a mutable reference to the 2D vector tracking which cells have been visited,
                // ensuring the same cell isn't visited more than once in a single word's search path.
                &mut cellsVisited,
                // passes an empty vector representing the path taken to form the current word, 
                // which will be populated with cell positions as the search progresses.
                Vec::new(), 
                &mut wordsFound, // allows the search function to store found words and their paths
            );
        });
    });


    wordsFound // Return the found words and their paths
}

// Builds a trie from a list of words for efficient prefix and word checking.
fn build_trie(words: &[String]) -> TrieNode {
    let mut trie = TrieNode::new(); // Create a new TrieNode
    words.iter().for_each(|word| trie.insert(word)); // Insert each word into the trie
    trie
}

impl TrieNode {
    // Creates a new TrieNode instance.
    fn new() -> Self {
        TrieNode {
            children: HashMap::new(), // Initialize with no children
            is_word_end: false, // Not a word end by default
        }
    }

    // Inserts a word into the trie.
    fn insert(&mut self, word: &str) {
        let mut node = self; // Start from the root of the trie.
        // Iterate through each character of the word.
        for ch in word.chars() {
            // For each character, either find the child node or create a new one if it doesn't exist.
            // Then, move to this child node for the next character.
            node = node.children.entry(ch).or_insert_with(TrieNode::new); // Insert or navigate to the next node
        }
        // After inserting all characters, mark the last node as the end of a word.
        node.is_word_end = true; // Mark the end of a word
    }

    // Checks if the trie contains a given prefix.
    fn contains_prefix(&self, prefix: &str) -> bool {
        let mut node = self; // Start from the root of the trie.
        // Iterate through each character in the prefix.
        for ch in prefix.chars() {
            // Try to move to the child node corresponding to the current character.
            match node.children.get(&ch) {
                // If the child node exists, proceed to this node for checking the next character.
                Some(n) => node = n,
                // If at any point the child node doesn't exist for the current character, return false.
                None => return false, // Return false if a character in the prefix is not found
            }
        }
        // If all characters in the prefix are found in consecutive nodes in the trie, return true.
        true // Prefix found
    }


    // Checks if the trie contains a complete word.
    fn contains_word(&self, word: &str) -> bool {
            // Start with the current trie node.
            let mut node = self;
            // Iterate through each character in the word.
            for ch in word.chars() {
                // Attempt to retrieve the child node corresponding to the current character.
                match node.children.get(&ch) {
                    // If the child node exists, proceed to this node for the next character.
                    Some(n) => node = n,
                None => return false, // Return false if a character in the word is not found
            }
        }
        node.is_word_end // Check if the current node marks the end of a word
    }
}

// Searches for words starting from a specific cell on the Boggle board.
fn search(
    trie: &TrieNode, // Trie structure containing valid words for efficient search
    board: &[&str], // The Boggle board represented as a slice of strings
    currentRow: isize, // Current row position in the board being searched
    currentColumn: isize, // Current column position in the board being searched
    currentWord: String, // Current word formed from the path taken so far
    visitedCells: &mut Vec<Vec<bool>>, // 2D vector tracking visited cells to prevent revisiting
    path: Vec<(u8, u8)>, // The current path of cells (row, column) visited to form the current word
    foundWordsMap: &mut HashMap<String, Vec<(u8, u8)>>, // Map to store found words and their corresponding paths
) {
    // Check for out-of-bounds or previously visited cells
    // Checks if the current row is within the bounds of the board.
    if !(0..board.len() as isize).contains(&currentRow) || 
       // Checks if the current column is within the bounds of the board.
       !(0..board[0].len() as isize).contains(&currentColumn) ||
       // Checks if the current cell has already been visited 
       visitedCells[currentRow as usize][currentColumn as usize] {
        return;   // If any of these conditions are true, the function returns early to prevent invalid or redundant searches.
    }
    
    // Attempt to add the current cell's character to the word
    let ch = match board.get(currentRow as usize).and_then(|r| r.chars().nth(currentColumn as usize)) {
        Some(c) => c,  // Successfully retrieved the character from the board.
        None => return,  // Early return if the row or character cannot be accessed.
    };

    let newWord = format!("{}{}", currentWord, ch); // Form a new word with the current character
    if !trie.contains_prefix(&newWord) {
        return; // Stop if the new word is not a valid prefix
    }

    // Clone the current path to create a new path for the next recursive step.
    let mut new_path = path.clone();
    new_path.push((currentRow as u8, currentColumn as u8)); // Add the current cell to the path

    // If the new word is valid, add it to the found words map
    if trie.contains_word(&newWord) {
        foundWordsMap.entry(newWord.clone()).or_insert_with(|| new_path.clone());
    }

    visitedCells[currentRow as usize][currentColumn as usize] = true; // Mark the current cell as visited

    // Directions to move on the Boggle board
    let searchDirections = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)];
    // Recursively search in all directions from the current cell
    for &(dx, dy) in &searchDirections {
        search(trie, board, currentRow + dx, currentColumn + dy, newWord.clone(), visitedCells, new_path.clone(), foundWordsMap);
    }

    visitedCells[currentRow as usize][currentColumn as usize] = false; // Unmark the current cell
}



#[cfg(test)]
#[path = "tests.rs"]
mod tests; 

