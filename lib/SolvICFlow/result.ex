OBOB#file   result.ex
#author mi-na
#date   18/01/24

defmodule SolvICFlow.Result do
  @compile [:native, {:hipe, [:verbose, :o3]}]

  def result_builder path, ite_times, tasks, remaining do
    working_tasks = Enum.reduce(Task.yield_many(tasks, 0), [], fn({task, status}, acm) ->
      if status != nil do
        acm
      else
        [task|acm]
      end end)
    if length(working_tasks) < 8 && length(remaining) > 0 do
      [next_task|tail] = remaining
      result_builder path, ite_times, [Task.async(next_task)|working_tasks], tail
    else
      receive do
        {:progress, client} ->
          send client, {:progress, ite_times, self}
          result_builder path, ite_times, working_tasks, remaining
        {:result, data, _output_server} ->
          if rem(ite_times, 100) == 0, do: File.mkdir(path <> "/" <> Integer.to_string(div ite_times, 100))
          write_fn = fn ->
            {:ok, file} = File.open (path <> "/" <> Integer.to_string(div ite_times, 100) <> "/" <> Integer.to_string(ite_times)), [:write]
            #json data allows only list (tuple is invalid)
            map_data = Enum.reduce([:u, :v, :p], %{}, fn(kind, acm) ->
              Map.put acm, kind, Enum.map(Tuple.to_list(data[kind]), &(Tuple.to_list &1))
            end)
            {:ok, json_data} = Poison.encode map_data
            IO.puts "[Info] writing the #{inspect ite_times}th data..."
            IO.binwrite file, json_data
          end
          result_builder path, ite_times+1, working_tasks, remaining ++ [write_fn]
        {:finish, client} ->
          if (length(tasks) + length(remaining)) == 0 do
            send client, true
          else
            send client, false
            result_builder path, ite_times, working_tasks, remaining
          end
      after 1000 ->
          result_builder path, ite_times, working_tasks, remaining
      end
    end
  end

  def getProgress name do
    send :global.whereis_name(name <> "_result"), {:progress, self}
    receive do
      {:progress, value, _} -> value
    end
  end

  def hasFinished? name do
    send :global.whereis_name(name <> "_result"), {:finish, self}
    receive do
      status -> status
    end
  end

  def genRBuilder name, path do
    File.mkdir(path <> "/0")
    pid = spawn(__MODULE__, :result_builder, [path, 1, [], []])
    :global.register_name(name <> "_result", pid)
    pid
  end

  def genJsonOutputCallback name, path do
    #pid = genRBuilder name, path
    fn({simbol, data}) ->
      case simbol do
        :ok ->
          send :global.whereis_name(name <> "_result"), {:result, data, self}
        :error ->
          IO.puts "[Error] emitError is called."
          IO.inspect data
      end
    end
  end
end # SolvICFlow.Result
