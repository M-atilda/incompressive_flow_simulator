#file   output.ex
#author mi-na
#date   18/01/13
#brief  provide a socket for the program to send data
#       at upper side, the behavior of sending is determined as a callback function

defmodule SolvICFlow.Output do
  @name :g_output_server

  def emitFlowData %SolvICFlow.FlowData{u: x_vel,
                                        v: y_vel,
                                        w: z_vel,
                                        p: pressure}do
    #TODO: padding
    velocity_status = List.zip List.flatten(x_vel), List.flatten(y_vel), List.flatten(z_vel)
    flow_status = List.zip velocity_status, pressure
    send :global.whereis_name(@name), {:emit, flow_status, self}
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
      {:emit, flow_status, _} ->
        output_callbcack.({:ok, flow_status})
      {:error, message, _} ->
        output_callbcack.({:error, message})
    end
    outputServer output_callbcack
  end

end #SolvICFlow.Output
