#file pressure.ex
#author mi-na
#date 18/01/12
#brief update pressure field following MAC method
#      as iteration method, it uses 2-level MultiGrids (V cycle) and SOR method in it

defmodule SolvICFlow.Pressure do
  @compile [:native, {:hipe, [:verbose, :o3]}]
  def update %SolvICFlow.FlowData{u: x_velocity,
                                  v: y_velocity,
                                  p: pressure,
                                  bc: _boundary_conditions,
                                  info: information}=flow_data,
    p_bc_field, name do
    %{:x_size => _x_size, :y_size => _y_size} = information

    # bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:p]

    {status, new_pressure} = CalcPServer.calcPre {x_velocity, y_velocity}, pressure, p_bc_field, information, name
    if status != :ok, do: IO.puts "[Info] pressure culculation hasn't converged in designated iteration times."

    %SolvICFlow.FlowData{ flow_data | p: new_pressure }
  end
end # SolvICFlow.Velocityocity
