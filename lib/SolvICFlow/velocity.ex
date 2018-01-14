#file   velocity.ex
#author mi-na
#date   18/01/12
#brief  update the velocity field following "Kawamura-Kuwahara" scheme (using artificial viscocity)

defmodule SolvICFlow.Velocity do
  def update  %tagFlowData{u: x_velocity,
                           v: y_velocity,
                           w: z_velocity,
                           p: pressure,
                           bc: boundary_conditions,
                           info: information}=flow_data do
    velocitys_field = {x_velocity, y_velocity, z_velocity}
    %{:x_size => x_size, :y_size => y_size, :z_size => z_size} = information
    u_bc_field = SolvICFlow.BCInfo.genBCField (0..x_size, 0..y_size, 0..z_size), boundary_conditions[:u]
    v_bc_field = SolvICFlow.BCInfo.genBCField (0..x_size, 0..y_size, 0..z_size), boundary_conditions[:v]
    w_bc_field = SolvICFlow.BCInfo.genBCField (0..x_size, 0..y_size, 0..z_size), boundary_conditions[:w]

    new_x_velocity = Task.async(CalcVServer.calcVel :u, velocitys_field, pressure, u_bc_field, information)
    new_y_velocity = Task.async(CalcVServer.calcVel :v, velocitys_field, pressure, v_bc_field, information)
    new_z_velocity = Task.async(CalcVServer.calcVel :w, velocitys_field, pressure, z_bc_field, information)

    %tagFlowData{ flow_data |
                  u: Task.await(new_x_velocity),
                  v: Task.await(new_y_velocity),
                  w: Task.await(new_z_velocity)}
  end
end # SolvICFlow.Velocity
