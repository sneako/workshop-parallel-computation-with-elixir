defmodule Lab4 do
  def sum_enumerable(enum) do
    Flow.from_enumerable(enum)
    |> Flow.reduce(fn -> 0 end, &+/2)
    |> Flow.emit(:state)
    |> Enum.sum()
  end

  def most_frequent_words(file_path, num) do
    File.stream!(file_path)
    |> Flow.from_enumerable()
    |> Flow.map(&String.trim/1)
    |> Flow.flat_map(&String.split(&1, " ", trim: true))
    |> Flow.map(&normalize_string/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      case acc do
        %{^word => count} ->
          Map.put(acc, word, count + 1)

        %{} ->
          Map.put(acc, word, 1)
      end
    end)
    |> Flow.take_sort(num, fn {_, count1}, {_, count2} -> count1 >= count2 end)
    |> Enum.to_list()
    |> hd()
    |> Enum.map(&elem(&1, 0))
  end

  defp normalize_string(string) do
    string
    |> String.downcase()
    |> String.replace(~w(, ? . ! ; _ “ ”), "")
  end
end
