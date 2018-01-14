#file   init.ex
#author mi-na
#date   18/01/12
#brief  generate the calculation field's data
#         referencing the information about its size, obstacles and boundary conditions

defmodule SolvICFlow.Init do

  import SolvICFlow.BCInfo, only: [ genBCInfoMap: 1 ]

  def genFlow %{:width => width,
                :height => height,
                :depth => depth,
                :space_step => space_step,
                :time_step => time_step,
                :init_velocity => [u_val, v_val, z_val],
                :init_pressure => p_val,
                :Re => re,
                :bc_strings => bc_strings} do
    x_size = round(depth / space_step)
    y_size = round(depth / space_step)
    z_size = round(depth / space_step)
    gen_field_fn = fn(val) ->
      List.duplicate(
        List.duplicate(
          List.duplicate(val, x_size), y_size), z_size) end
    %tagFlowData{u: gen_field_fn(u_val),
                 v: gen_field_fn(v_val),
                 w: gen_field_fn(w_val),
                 p: gen_field_fn(p_val),
                 bc: genBCInfoMap(bc_strings),
                 info: %{:Re => re,
                         :CFL_number => space_step / time_step,
                         :dt => time_step,
                         :dx => space_step,
                         :dy => space_step,
                         :dz => space_step,
                         :x_size => x_size,
                         :y_size => y_size,
                         :z_size => z_size}}
  end

end # SolvICFlow.Init
