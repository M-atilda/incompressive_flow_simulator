#file   output.ex
#author mi-na
#date   18/01/13
#brief  provide a socket for the program to send data
#       at upper side, the behavior of sending is determined as a callback function

defmodule SolvICFlow.Output do
  @name :g_output_server

  def emitFlowData %SolvICFlow.FlowData{u: _x_vel,
                                        v: _y_vel,
                                        p: _pressure}=flow_data do
    #TODO: padding
    send :global.whereis_name(@name), {:emit, flow_data, self}
    flow_data
  end

  def emitError message do
    send :global.whereis_name(@name), {:error, message, self}
  end

  def initOServer output_callbcack do
    pid = spawn(__MODULE__, :outputServer, [output_callbcack])
    :global.register_name(@name, pid)
  end


  def outputServer output_callbcack do
    receive do
      {:emit, flow_data, _} ->
        output_callbcack.({:ok, flow_data})
      {:error, message, _} ->
        output_callbcack.({:error, message})
    end
    outputServer output_callbcack
  end


  def sampleCallbackImpl %SolvICFlow.FlowData{u: x_vel,
                                              v: y_vel,
                                              p: pressure}, {x_size, y_size}, space do
    x_step = round(x_size / space)
    y_step = round(y_size / space)

    # IO.puts "[Result] U field\n#{inspect genMiniField(x_vel, x_step, y_step, space)}"
    # IO.puts "[Result] V field\n#{inspect genMiniField(y_vel, x_step, y_step, space)}"
    # IO.puts "[Result] P field\n#{inspect genMiniField(pressure, x_step, y_step, space)}"
    IO.puts "[Info] current results."
    genMiniField(x_vel, x_step, y_step, space)
    genMiniField(y_vel, x_step, y_step, space)
    genMiniField(pressure, x_step, y_step, space)
  end
  defp genMiniField field, x_step, y_step, space do
    half_space = round(space / 2)
    for j <- 1..(y_step-2) do
      for i <- 1..(x_step-2) do
        getAver field, {i*space+half_space, j*space+half_space}
      end
      |> IO.inspect
    end
  end
  defp getAver f, {i, j} do
    id(f, {i,j}) / 4 + (id(f, {i,j-1}) + id(f, {i,j+1}) + id(f, {i-1,j}) + id(f, {i+1,j})) / 8 + (id(f, {i-1,j-1}) + id(f, {i-1,j+1}) + id(f, {i+1,j-1}) + id(f, {i+1,j+1})) / 16
  end
  defp id field, {i,j} do
    Enum.at(Enum.at(field, j), i)
  end

end #SolvICFlow.Output
