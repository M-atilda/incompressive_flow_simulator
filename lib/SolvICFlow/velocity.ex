#file   velocity.ex
#author mi-na
#date   18/01/12
#brief  update the velocity field following "Kawamura-Kuwahara" scheme (using artificial viscocity)

defmodule SolvICFlow.Velocity do

  def update %SolvICFlow.FlowData{u: x_velocity,
                                  v: y_velocity,
                                  p: pressure,
                                  bc: boundary_conditions,
                                  info: information}=flow_data do
    velocitys_field = {x_velocity, y_velocity}
    %{:x_size => x_size, :y_size => y_size} = information
    u_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:u]
    v_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:v]

    new_x_velocity = CalcVServer.calcVel :u, velocitys_field, pressure, u_bc_field, information
    new_y_velocity = CalcVServer.calcVel :v, velocitys_field, pressure, v_bc_field, information

    %SolvICFlow.FlowData{ flow_data |
                          u: new_x_velocity,
                          v: new_y_velocity}
  end
end # SolvICFlow.Velocity
