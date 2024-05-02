#[cfg(test)]
mod tests {
    
    use super::super::{*};
    use std::iter::FromIterator;
    use std::collections::HashSet;
   
    #[test]
    fn test_finds_horizontal_and_vertical_words_on_a_2x2_board() {
        let board = ["ab", "ba"];
        let words = vec!["ab".to_string(), "ba".to_string()];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Words are not legal.");
        assert!(words_in_board(&result, &board), "Words do not fit on the board as expected.");
        assert!(words_coords_ok(&result), "Coordinates of words are not adjacent as required.");

        let score = get_score(&result);
        assert_eq!(score, 4, "Score calculation mismatch."); // Assuming each word scores 2 points
    }

    #[test]
    fn test_finds_diagonal_words_on_a_board() {
        let board = ["cat", "bta", "dek"];
        let words = vec!["cat".to_string(), "bet".to_string()];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Words are not legal.");
        assert!(words_in_board(&result, &board), "Words do not fit on the board as expected.");
        assert!(words_coords_ok(&result), "Coordinates of words are not adjacent as required.");

        let score = get_score(&result);
        assert!(score > 0, "Score should be greater than zero.");
    }

    #[test]
    fn test_handles_overlapping_words_correctly() {
        let board = ["sos", "oat", "mom"];
        let words = vec!["so".to_string(), "sat".to_string(), "mom".to_string()];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Words are not legal.");
        assert!(words_in_board(&result, &board), "Words do not fit on the board as expected.");
        assert!(words_coords_ok(&result), "Coordinates of words are not adjacent as required.");

        let score = get_score(&result);
        assert!(score > 0, "Score should be greater than zero.");
    }

    #[test]
    fn test_recognizes_words_requiring_backtracking() {
        let board = ["star", "urms", "tart", "stun"];
        let words = vec!["start".to_string(), "stun".to_string(), "tart".to_string(), "rum".to_string()];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Words are not legal.");
        assert!(words_in_board(&result, &board), "Words do not fit on the board as expected.");
        assert!(words_coords_ok(&result), "Coordinates of words are not adjacent as required.");

        let score = get_score(&result);
        assert!(score > 0, "Score should be greater than zero.");
    }

    fn setup_test_board_and_words() -> (Vec<&'static str>, Vec<String>) {
        let board = vec!["ab", "ba"];
        let words = vec!["ab".to_string(), "ba".to_string()];
        (board, words)
    }

    #[test]
    fn test_boggle_board_validations() {
        let (board, words) = setup_test_board_and_words();
        let found = boggle(&board, &words);

        assert!(words_legal(&found, &words), "Not all found words are legal.");
        assert!(words_in_board(&found, &board), "Words do not fit on the board as expected.");
        assert!(words_coords_ok(&found), "Word coordinates are not correctly adjacent.");
        
        let score = get_score(&found);
        println!("Total score: {}", score);
        assert!(score > 0, "Score should be greater than zero.");
    }

    #[test]
    fn test_basic_functionality_on_a_2x2_board() {
        let board = ["ea", "te"];
        let words = vec!["eat".to_string(), "tea".to_string(), "ate".to_string()];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Returned words not in list");
        assert!(words_in_board(&result, &board), "Returned words not in board");
        let score = get_score(&result);
        println!("2x2 Basic Test Passed with score: {}", score);
    }

    #[test]
    fn test_all_directions_word_search_on_a_4x4_board() {
        let board = ["soup", "rope", "abnd", "nerd"];
        let words = vec![
            "soup".to_string(), "rope".to_string(), "nerd".to_string(), 
            "den".to_string(), "open".to_string(), "pen".to_string()
        ];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Returned words not in list");
        assert!(words_in_board(&result, &board), "Returned words not in board");
        let score = get_score(&result);
        println!("4x4 All Directions Test Passed with score: {}", score);
    }

    #[test]
    fn test_embedded_board_and_word_list_on_an_8x8_board() {
        let board = [
            "connecti", "oleaders", "nnetwork", "programm",
            "algorith", "function", "variable", "constant"
        ];
        let words = vec![
            "connection".to_string(), "leadership".to_string(), "network".to_string(),
            "programming".to_string(), "algorithm".to_string(), "function".to_string(),
            "variable".to_string(), "constant".to_string(), "binary".to_string(), 
            "framework".to_string()
        ];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Returned words not in list");
        assert!(words_in_board(&result, &board), "Returned words not in board");
        let score = get_score(&result);
        println!("Embedded 8x8 Test Passed with score: {}", score);
    }

    #[test]
    fn test_embedded_board_and_word_list_on_a_16x16_board() {
        let board = [
            "configurationalx", "establishmentryz", "microprocessorwk", "telecommunication",
            "infrastructuredp", "superintendentvq", "multidimensional", "decentralization",
            "intercontinental", "philanthropistmc", "misinterpretatio", "technologicallyu",
            "incompatibilities", "disproportionate", "anthropologicalf", "counterproductive"
        ];
        let words = vec![
            "configuration".to_string(), "establishment".to_string(), "microprocessor".to_string(),
            "telecommunication".to_string(), "infrastructure".to_string(), "superintendent".to_string(),
            "multidimensional".to_string(), "decentralization".to_string(), "intercontinental".to_string(),
            "philanthropist".to_string(), "misinterpretation".to_string(), "technologically".to_string(),
            "incompatibilities".to_string(), "disproportionate".to_string(), "anthropological".to_string(),
            "counterproductive".to_string()
        ];
        let result = boggle(&board, &words);

        assert!(words_legal(&result, &words), "Returned words not in list");
        assert!(words_in_board(&result, &board), "Returned words not in board");
        let score = get_score(&result);
        println!("Embedded 16x16 Test Passed with score: {}", score);
    }
    

    fn words_legal(found: &HashMap<String, Vec<(u8, u8)>>, words: &[String]) -> bool {
        let word_set: HashSet<String> = words.iter().cloned().collect();
        found.keys().all(|word| word_set.contains(word))
    }    

    fn words_in_board(found: &HashMap<String, Vec<(u8, u8)>>, board: &[&str]) -> bool {
        found.iter().all(|(word, coords)| {
            word.chars().zip(coords).all(|(ch, &(x, y))| {
                board.get(x as usize).and_then(|row| row.chars().nth(y as usize)) == Some(ch)
            })
        })
    }    

    fn words_coords_ok(found: &HashMap<String, Vec<(u8, u8)>>) -> bool {
        found.values().all(|coords| {
            coords.windows(2).all(|window| {
                // Correct destructuring of a slice of references to tuples
                if let [first, second] = window {
                    let (x1, y1) = *first;
                    let (x2, y2) = *second;
                    let xd = (x1 as i8 - x2 as i8).abs();
                    let yd = (y1 as i8 - y2 as i8).abs();
                    xd <= 1 && yd <= 1
                } else {
                    false
                }
            })
        })
    }
    
    fn get_score(found: &HashMap<String, Vec<(u8, u8)>>) -> u32 {
        let scores = [1, 2, 4, 6, 9, 12, 16, 20];
        found.keys().map(|word| {
            scores.get(word.len().saturating_sub(1)).copied().unwrap_or(20)
        }).sum()
    }
    

    fn get_cell(coord: (u8, u8), board: &[&str]) -> char {
        board.get(coord.0 as usize)
             .and_then(|row| row.chars().nth(coord.1 as usize))
             .unwrap_or('\0')
    }
    

}

