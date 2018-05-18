defmodule Lab1 do
  def print_first_message() do
    spawn(fn ->
      receive do
        msg -> IO.write(:stderr, msg)
      end
    end)
  end

  def print_all_messages() do
    spawn(&print_all_loop/0)
  end

  defp print_all_loop() do
    receive do
      msg ->
        IO.write(:stderr, msg)
        print_all_loop()
    end
  end

  def sum() do
    spawn(fn ->
      receive do
        {:sum, caller, range} ->
          sum = Enum.sum(range)
          send(caller, sum)
      end
    end)
  end

  def sum_all(list_of_lists) do
    Stream.map(list_of_lists, fn list ->
      ref = make_ref()
      summer = spawn(fn ->
        receive do
          {:sum, caller, range} ->
            sum = Enum.sum(range)
            send(caller, {ref, sum})
        end
      end)
      send(summer, {:sum, self(), list})
      ref
    end)
    |> Enum.map(fn ref ->
      receive do
        {^ref, sum} -> sum
      end
    end)
  end
end
