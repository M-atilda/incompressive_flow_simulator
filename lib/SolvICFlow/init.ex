#file   init.ex
#author mi-na
#date   18/01/12
#brief  generate the calculation field's data
#         referencing the information about its size, obstacles and boundary conditions

defmodule SolvICFlow.Init do
  import SolvICFlow.BCInfo, only: [ genBCInfoMap: 2 ]

  def genFlow %{:width => width,
                :height => height,
                :space_step => space_step,
                :CFL_number => cfl_number,
                :init_velocity => [u_val, v_val],
                :init_pressure => p_val,
                :Re => re,
                :bc_strings => bc_strings} do
    #NOTE: include both edge, its size is odd number
    x_size = if (rem(round(width/space_step)+1, 2) != 0), do: round(width/space_step)+1, else: round(width/space_step)
    y_size = if (rem(round(height/space_step)+1, 2) != 0), do: round(height/space_step)+1, else: round(height/space_step)
    gen_field_fn = fn(val) ->
      List.duplicate(
        List.duplicate(val, x_size), y_size) end
    %SolvICFlow.FlowData{u: gen_field_fn.(u_val),
                         v: gen_field_fn.(v_val),
                         p: gen_field_fn.(p_val),
                         bc: genBCInfoMap(bc_strings, space_step),
                         info: %{:Re => re,
                                 :dt => cfl_number * space_step,
                                 :dx => space_step,
                                 :dy => space_step,
                                 :x_size => x_size,
                                 :y_size => y_size}}
  end

end # SolvICFlow.Init
