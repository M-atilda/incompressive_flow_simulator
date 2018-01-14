#file pressure.ex
#author mi-na
#date 18/01/12
#brief update pressure field following MAC method
#      as iteration method, it uses 2-level MultiGrids (V cycle) and SOR method in it

defmodule SolvICFlow.Pressure do
  def update %tagFlowData{u: x_velocity,
                          v: y_velocity,
                          w: z_velocity,
                          p: pressure,
                          bc: boundary_conditions,
                          info: information}=flow_data do
    %{:x_size => x_size, :y_size => y_size, :z_size => z_size} = information
    bc_field = SolvICFlow.BCInfo.genBCField (0..x_size, 0..y_size, 0..z_size), boundary_conditions[:p]
    new_pressure = CalcPServer.calcPre {x_velocity, y_velocity, z_velocity}, pressure, bc_field, information
    %tagFlowData{ flow_data | p: new_pressure }
  end
end # SolvICFlow.Velocityocity
