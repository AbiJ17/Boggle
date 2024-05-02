defmodule Boggle do

  @moduledoc """
    Add your boggle function below. You may add additional helper functions if you desire. 
    Test your code by running 'mix test' from the tester_ex_simple directory.
  """

  def boggle(board, words) do
    # Create a set of valid words for fast lookup
    valid_words = MapSet.new(words)
    # Construct a set of valid prefixes (word starts) from the list of words
    valid_starts = construct_valid_starts_set(words)
    # Determine minimum length among all given words
    minimum_length_of_words = minimum_length_of_words(words)
    
    # Traverse the board to find all words that can be formed, then format the found words' paths for the output
    board
    |> traverse_board(valid_words, valid_starts, minimum_length_of_words)
    |> format_found_words()  
  end

  # Wrapper function to initiate the recursion for finding minimum word length
  # Takes a list of words and starts the process with an initial maximum value
  defp minimum_length_of_words(words), do: minimum_length_of_words(words, :infinity)

  # Base case for the recursive function to find minimum word length
  # When list is empty, return the accumulated minimum length
  defp minimum_length_of_words([], minimum_length), do: minimum_length

  # Recursive function to find minimum word length in a list of words
  # Compares each word length against the current minimum and updates it if necessary
  defp minimum_length_of_words([word | rest], minimum_length) do
    word_length = String.length(word)
    new_minimum_length = if word_length < minimum_length, do: word_length, else: minimum_length
    minimum_length_of_words(rest, new_minimum_length)
  end

  # Traverses the entire board to find all valid words
  defp traverse_board(board, valid_words, valid_starts, minimum_length_of_words) do
    # Determine the size of the board
    board_size = tuple_size(board)
    # Iterate over each row of the board
    Enum.reduce(0..board_size - 1, %{}, fn row, final_acc ->
      # For the current row, iterate over each column
      Enum.reduce(0..board_size - 1, final_acc, fn col, temp_acc ->
        # Search for valid words starting from the current cell (row, col)
        # Accumulate found words and their paths in temp_acc
        search(board, row, col, "", %{}, valid_starts, valid_words, temp_acc, [], minimum_length_of_words)
      end)
    end)
  end

  # Prepares the found words and their paths for final output
  defp format_found_words(words_with_paths) do
    # Converts the map of words with paths to a list and then formats them recursively
    words_with_paths
    |> Map.to_list()
    |> format_found_words_recursive(%{})
  end

  # Base case for the recursive formatting function; return the accumulated results
  defp format_found_words_recursive([], final_acc), do: final_acc

  # Recursively formats each word and its path, reversing the path for correct ordering
  defp format_found_words_recursive([{word, traversal_path} | rest], final_acc) do
    # Reverse the traversal path to ensure it's in the correct order
    reversed_path = reverse_path(traversal_path, [])
    # Add the word and its reversed path to the accumulator
    updated_acc = Map.put(final_acc, word, reversed_path)
    # Continue processing the rest of the words
    format_found_words_recursive(rest, updated_acc)
  end

  # Reverses the traversal path list
  # Base case: when the list is empty, return the accumulated (reversed) path
  defp reverse_path([], final_acc), do: final_acc

  # Recursive case: takes the first element (head) and prepends it to the accumulator, effectively reversing the list as it's reconstructed
  defp reverse_path([head | tail], final_acc), do: reverse_path(tail, [head | final_acc])

  # Main search function to find words on the board starting from a specific cell
  defp search(board, row, col, valid_start, explored_positions, valid_starts, valid_words, final_acc, traversal_path, minimum_length_of_words) do
    # Determine the size of the board to ensure we don't search out of bounds
    board_size = tuple_size(board)
    # Check if the current cell is out of bounds or already explored
    # If so, return current accumulator
    if Map.get(explored_positions, {row, col}) || row < 0 || col < 0 || row >= board_size || col >= tuple_size(elem(board, 0)) do
      final_acc
    else
      # Append the current cell's value to valid_start to form a new potential valid word
      new_valid_start = valid_start <> cell_value(board, {row, col})
      # Mark the current cell as explored
      new_explored_positions = Map.put(explored_positions, {row, col}, true)
      # Add the current cell to the traversal path
      new_traversal_path = [{row, col} | traversal_path]
      
      # Check if the new valid start forms a valid word and update final accumulator accordingly
      new_final_acc = update_if_word_valid(new_valid_start, valid_words, new_traversal_path, final_acc, minimum_length_of_words)
    
      # Continue the search from the current cell, passing along the updated state
      continue_search(new_valid_start, board, {row, col}, new_explored_positions, valid_starts, valid_words, new_final_acc, new_traversal_path, minimum_length_of_words)
    end
  end

  # Retrieves the value from the board at the specified row and column
  defp cell_value(board, {row, col}) do
    elem(elem(board, row), col)
  end

  # Updates the final accumulator if the valid_start forms a valid word of adequate length
  defp update_if_word_valid(valid_start, valid_words, new_traversal_path, final_acc, minimum_length_of_words) do
    # Check if the current string is a valid word and meets the minimum length requirement
    if String.length(valid_start) >= minimum_length_of_words and MapSet.member?(valid_words, valid_start) do
      # Update the accumulator with the valid word and its path
      Map.put(final_acc, valid_start, new_traversal_path)
    else
      # Return the accumulator unchanged if the word is not valid
      final_acc
    end
  end

  # Decides whether to continue searching for words from the current position
  defp continue_search(valid_start, board, {row, col}, explored_positions, valid_starts, valid_words, final_acc, traversal_path, minimum_length_of_words) do
    # Checks if the current prefix is a valid start for any word
    if MapSet.member?(valid_starts, valid_start) do
      # If so, explore all possible directions from this position
      explore_all_directions(board, row, col, valid_start, explored_positions, valid_starts, valid_words, final_acc, traversal_path, minimum_length_of_words)
    else
      # Otherwise, no further search is needed; return the current accumulator
      final_acc
    end
  end
  
  # Explores all possible directions from the current position to find valid words
  defp explore_all_directions(board, row, col, valid_start, explored_positions, valid_starts, valid_words, initial_acc, traversal_path, minimum_length_of_words) do
    # Iterates over all possible movement deltas in x and y directions
    Enum.reduce([-1, 0, 1], initial_acc, fn dx, outer_direction_acc ->
      Enum.reduce([-1, 0, 1], outer_direction_acc, fn dy, inner_direction_acc ->
        # Checks if moving in the (dx, dy) direction is valid and within the board
        if valid_direction?(dx, dy) and within_board?(board, row + dx, col + dy) do
          # Continues the search from the new position if valid
          search(board, row + dx, col + dy, valid_start, explored_positions, valid_starts, valid_words, inner_direction_acc, traversal_path, minimum_length_of_words)
        else
          # Otherwise, retains the current state of the accumulator
          inner_direction_acc
        end
      end)
    end)
  end

  # Determines if a direction is valid (not staying in the same position)
  defp valid_direction?(dx, dy) do
    dx != 0 or dy != 0
  end

  # Checks if a given position is within the bounds of the board
  defp within_board?(board, row, col) do
    board_size = tuple_size(board)
    row >= 0 and col >= 0 and row < board_size and col < tuple_size(elem(board, row))
  end

  # Constructs a set of valid starting prefixes from the list of words
  defp construct_valid_starts_set(words) do
    # Generates sets of valid start sequences for each word and unites them into a single set
    words
    |> Enum.map(&generate_valid_starts_as_set/1) 
    |> Enum.reduce(MapSet.new(), &MapSet.union/2)
  end

  # Generates a MapSet of all valid start sequences for a given word
  defp generate_valid_starts_as_set(word) do
    # Maps each position in the word to its prefix and converts the list to a MapSet
    0..String.length(word) - 1
    |> Enum.map(fn position -> String.slice(word, 0..position) end)
    |> MapSet.new() 
  end
end

