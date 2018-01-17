#file pressure.ex
#author mi-na
#date 18/01/12
#brief update pressure field following MAC method
#      as iteration method, it uses 2-level MultiGrids (V cycle) and SOR method in it

defmodule SolvICFlow.Pressure do

  def update %SolvICFlow.FlowData{u: x_velocity,
                                  v: y_velocity,
                                  p: pressure,
                                  bc: boundary_conditions,
                                  info: information}=flow_data do
    %{:x_size => x_size, :y_size => y_size} = information
    bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:p]
    {status, new_pressure} = CalcPServer.calcPre {x_velocity, y_velocity}, pressure, bc_field, information
    if status != :ok, do: IO.puts "[Info] pressure culclation hasn't converged in designated iteration times."

    %SolvICFlow.FlowData{ flow_data | p: new_pressure }
  end
end # SolvICFlow.Velocityocity
