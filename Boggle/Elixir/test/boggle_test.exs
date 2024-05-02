defmodule BoggleTest do
  use ExUnit.Case
  alias Boggle

  doctest Boggle

  # Test finds diagonal words on a board
  test "finds diagonal words on a board" do
    board = {
      {"c", "a", "t"},
      {"b", "t", "a"},
      {"d", "e", "k"}
    }
    words = ["cat", "bet"]

    result = Boggle.boggle(board, words)
    assert result == %{"bet" => [{1, 0}, {2, 1}, {1, 1}], "cat" => [{0, 0}, {0, 1}, {1, 1}]}
  end

  # Test recognizes words requiring backtracking
  test "recognizes words requiring backtracking" do
    board = {
      {"s", "t", "a", "r"},
      {"u", "r", "m", "s"},
      {"t", "a", "r", "t"},
      {"s", "t", "u", "n"}
    }
    words = ["start", "stun", "tart", "rum"]

    result = Boggle.boggle(board, words)
    assert result == %{"start" => [{3, 0}, {3, 1}, {2, 1}, {2, 2}, {2, 3}], "stun" => [{3, 0}, {3, 1}, {3, 2}, {3, 3}], "tart" => [{3, 1}, {2, 1}, {2, 2}, {2, 3}]}
  end

  # Test handles overlapping words correctly
  test "handles overlapping words correctly" do
    board = {
      {"s", "o", "s"},
      {"o", "a", "t"},
      {"m", "o", "m"}
    }
    words = ["so", "sat", "mom"]

    result = Boggle.boggle(board, words)
    assert result == %{"mom" => [{2, 2}, {2, 1}, {2, 0}], "sat" => [{0, 2}, {1, 1}, {1, 2}], "so" => [{0, 2}, {0, 1}]}
  end

  # Test finds horizontal and vertical words on a 2x2 board
  test "finds horizontal and vertical words on a 2x2 board" do
    board = {
      {"a", "b"},
      {"b", "a"}
    }
    words = ["ab", "ba"]

    result = Boggle.boggle(board, words)
    assert result == %{"ab" => [{1, 1}, {1, 0}], "ba" => [{1, 0}, {1, 1}]}
  end

  test "basic functionality on a 2x2 board" do
    words = ["eat", "tea", "ate"]
    board = {{"e", "a"}, {"t", "e"}}
    found = Boggle.boggle(board, words)
    
    # Validate the results
    assert validate_return_type(found), "Return type not correct"
    assert wordsLegal?(found, words), "Returned words not in list"
    assert wordsInBoard?(found, board), "Returned words not in board"

    # Calculate and log the score
    score = getScore(found)
    IO.puts "2x2 Basic Test Passed with score: #{score}"
  end

  test "all directions word search on a 4x4 board" do
    words = ["soup", "rope", "nerd", "den", "open", "pen"]
    board = {{"s", "o", "u", "p"}, {"r", "o", "p", "e"}, {"a", "b", "n", "d"}, {"n", "e", "r", "d"}}
    found = Boggle.boggle(board, words)
    
    # Validate the results
    assert validate_return_type(found), "Return type not correct"
    assert wordsLegal?(found, words), "Returned words not in list"
    assert wordsInBoard?(found, board), "Returned words not in board"

    # Calculate and log the score
    score = getScore(found)
    IO.puts "4x4 All Directions Test Passed with score: #{score}"
  end

  test "embedded board and word list on an 8x8 board" do
    # Predefined words
    words = [
      "connection", "leadership", "network", "programming", "algorithm",
      "function", "variable", "constant", "binary", "framework"
    ]

    # Predefined 8x8 board
    board = {
      {"c", "o", "n", "n", "e", "c", "t", "i"},
      {"o", "l", "e", "a", "d", "e", "r", "s"},
      {"n", "n", "e", "t", "w", "o", "r", "k"},
      {"p", "r", "o", "g", "r", "a", "m", "m"},
      {"a", "l", "g", "o", "r", "i", "t", "h"},
      {"f", "u", "n", "c", "t", "i", "o", "n"},
      {"v", "a", "r", "i", "a", "b", "l", "e"},
      {"c", "o", "n", "s", "t", "a", "n", "t"}
    }

    # Execute the Boggle game logic
    found = Boggle.boggle(board, words)
    
    # Validate the results
    assert validate_return_type(found), "Return type not correct"
    assert wordsLegal?(found, words), "Returned words not in list"
    assert wordsInBoard?(found, board), "Returned words not in board"

    # Calculate and log the score
    score = getScore(found)
    IO.puts "Embedded 8x8 Test Passed with score: #{score}"
  end

  test "embedded board and word list on a 16x16 board" do
    # Predefined words
    words = [
      "configuration", "establishment", "microprocessor", "telecommunication",
      "infrastructure", "superintendent", "multidimensional", "decentralization",
      "intercontinental", "philanthropist", "misinterpretation", "technologically",
      "incompatibilities", "disproportionate", "anthropological", "counterproductive"
    ]

    # Predefined 16x16 board
    board = {
      {"c", "o", "n", "f", "i", "g", "u", "r", "a", "t", "i", "o", "n", "a", "l", "x"},
      {"e", "s", "t", "a", "b", "l", "i", "s", "h", "m", "e", "n", "t", "r", "y", "z"},
      {"m", "i", "c", "r", "o", "p", "r", "o", "c", "e", "s", "s", "o", "r", "w", "k"},
      {"t", "e", "l", "e", "c", "o", "m", "m", "u", "n", "i", "c", "a", "t", "i", "o"},
      {"i", "n", "f", "r", "a", "s", "t", "r", "u", "c", "t", "u", "r", "e", "d", "p"},
      {"s", "u", "p", "e", "r", "i", "n", "t", "e", "n", "d", "e", "n", "t", "v", "q"},
      {"m", "u", "l", "t", "i", "d", "i", "m", "e", "n", "s", "i", "o", "n", "a", "l"},
      {"d", "e", "c", "e", "n", "t", "r", "a", "l", "i", "z", "a", "t", "i", "o", "n"},
      {"i", "n", "t", "e", "r", "c", "o", "n", "t", "i", "n", "e", "n", "t", "a", "l"},
      {"p", "h", "i", "l", "a", "n", "t", "h", "r", "o", "p", "i", "s", "t", "m", "c"},
      {"m", "i", "s", "i", "n", "t", "e", "r", "p", "r", "e", "t", "a", "t", "i", "o"},
      {"t", "e", "c", "h", "n", "o", "l", "o", "g", "i", "c", "a", "l", "l", "y", "u"},
      {"i", "n", "c", "o", "m", "p", "a", "t", "i", "b", "i", "l", "i", "t", "i", "e"},
      {"d", "i", "s", "p", "r", "o", "p", "o", "r", "t", "i", "o", "n", "a", "t", "e"},
      {"a", "n", "t", "h", "r", "o", "p", "o", "l", "o", "g", "i", "c", "a", "l", "f"},
      {"c", "o", "u", "n", "t", "e", "r", "p", "r", "o", "d", "u", "c", "t", "i", "v"}
    }

    # Execute the Boggle game logic
    found = Boggle.boggle(board, words)
    
    # Validate the results
    assert validate_return_type(found), "Return type not correct"
    assert wordsLegal?(found, words), "Returned words not in list"
    assert wordsInBoard?(found, board), "Returned words not in board"

    # Calculate and log the score
    score = getScore(found)
    IO.puts "Embedded 16x16 Test Passed with score: #{score}"
  end

  def validate_return_type(%{} = found) do
    found
    |> Map.values()
    |> Enum.any?(fn coords -> validate_coords_format(coords) end)
  end
  def validate_return_type(_), do: false
  defp validate_coords_format([{x, y} | _]) when is_integer(x) and is_integer(y), do: true
  defp validate_coords_format(_), do: false
  
  def wordsLegal?(found, words) do
    word_set = MapSet.new(words)
    found
    |> Map.keys()
    |> Enum.all?(fn word -> MapSet.member?(word_set, word) end)
  end
  
  def wordsInBoard?(found, board) do
    found
    |> Map.to_list()
    |> Enum.all?(fn {word, coords} -> 
      validate_word(board, word, coords) and validate_coords(coords)
    end)
  end
  defp validate_word(board, word, coords) do
    Enum.all?(Enum.zip(String.codepoints(word), coords), fn {char, {x, y}} -> 
      char == get_cell(board, x, y)
    end)
  end
  defp validate_coords(coords) do
    coords_unique?(coords) and coords_adjacent?(coords)
  end
  defp coords_unique?(coords), do: Enum.uniq(coords) == coords
  defp coords_adjacent?([{x, y} | _] = coords) do
    Enum.all?(Enum.zip(coords, tl(coords)), fn
      {{x1, y1}, {x2, y2}} -> abs(x1 - x2) <= 1 and abs(y1 - y2) <= 1
    end)
  end
  def get_cell(board, x, y), do: elem(elem(board, x), y)

  def getScore found do
    w_scores = {1, 2, 4, 6, 9, 12, 16, 20}  
    words = Map.keys found
    s = for w <- words, do: if( String.length(w) <= 8, do: elem(w_scores, String.length(w)-1), else: 20)
    Enum.sum s
  end
end


