#file   velocity.ex
#author mi-na
#date   18/01/12
#brief  update the velocity field following "Kawamura-Kuwahara" scheme (using artificial viscocity)

defmodule SolvICFlow.Velocity do
  @compile [:native, {:hipe, [:verbose, :o3]}]

  def update %SolvICFlow.FlowData{u: x_velocity,
                                  v: y_velocity,
                                  p: pressure,
                                  bc: _boundary_conditions,
                                  info: information}=flow_data,
  {u_bc_field, v_bc_field} do
    velocitys_field = {x_velocity, y_velocity}

    # u_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:u]
    # v_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:v]

    new_x_velocity = Task.async(fn -> CalcVServer.calcVel(:u, velocitys_field, pressure, u_bc_field, information) end)
    new_y_velocity = Task.async(fn -> CalcVServer.calcVel(:v, velocitys_field, pressure, v_bc_field, information) end)

    %SolvICFlow.FlowData{ flow_data |
                          u: Task.await(new_x_velocity, 60000),
                          v: Task.await(new_y_velocity, 60000)}
  end
end # SolvICFlow.Velocity
