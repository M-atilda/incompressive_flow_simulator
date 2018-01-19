#file   boundary.ex
#author mi-na
#date   18/01/13
#brief  boundary conditions are provided as a struct which is consists of the function to know whether the position is in the target area and value applied if in it
#       it is generated from simple mathematical condition expression (string)

defmodule SolvICFlow.BCInfo do
  #struct BCInfo
  #brief  represents a boundary condition
  #! cond_exp fn({float, float, float}) -> boolean end
  #! value float
  defstruct cond_exp: nil, value: 0

  defp applyBCInfo position, %SolvICFlow.BCInfo{cond_exp: is_in?, value: val} do
    if is_in?.(position) do
      val
    else
      false
    end
  end
  def genBCField {x_size, y_size}, boundary_conditions do
    for j <- 0..(y_size-1) do
      for i <- 0..(x_size-1) do
        Enum.reduce(boundary_conditions, false, fn(tag_bc, acm) ->
          if acm do
            acm
          else
            applyBCInfo {i,j}, tag_bc
          end
        end)
      end end
  end

  #! bc_info ["u=0;x=0,y=0", ...]
  def genBCInfoMap bc_info, space_step do
    keylist = bc_info
    |> Enum.map(fn(str) ->
      [val_exp_str, cond_str] = String.split str, ";"
      [kind, val_str] = String.split val_exp_str, "="
      if String.contains?(val_str, ".") do
        {kind, cond_str, String.to_float(val_str)}
      else
        {kind, cond_str, String.to_integer(val_str)}
      end end)
    |> Enum.map(fn({kind, cond_str, val}) ->
      {kind, bcInfoFactory(cond_str, val, space_step)} end)
    extract_bc_fn = fn(kind) ->
      {bc_taple, _rest} = Keyword.split keylist, [kind]
      Enum.map(bc_taple, fn({_kind, bc_tag}) -> bc_tag end) end
    Enum.reduce [:u, :v, :p], %{}, fn(kind, acm) ->
      Map.put acm, kind, extract_bc_fn.(Atom.to_string(kind)) end
  end
  defp bcInfoFactory cond_str, val, space_step do
    cond_exp_list = String.split(cond_str, ",")
                 |> Enum.map(fn(str) -> condStr2Exp(str, space_step) end)
    exp = fn(position) ->
      Enum.reduce cond_exp_list, true, fn(cond_exp, acm) ->
        acm && cond_exp.(position) end end
    %SolvICFlow.BCInfo{cond_exp: exp, value: val}
  end
  defp condStr2Exp cond_str, space_step do
    contains? = &(String.contains? cond_str, &1)
    {left, func} = cond do
      contains?.("<=") ->
        [l, r] = String.split cond_str, "<="
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 <= cell_num)}
      contains?.(">=") ->
        [l, r] = String.split cond_str, ">="
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 >= cell_num)}
      contains?.("=<") ->
        [l, r] = String.split cond_str, "=<"
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 <= cell_num)}
      contains?.("=>") ->
        [l, r] = String.split cond_str, "=>"
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 >= cell_num)}
      contains?.("=") ->
        [l, r] = String.split cond_str, "="
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 == cell_num)}
      contains?.("<") ->
        [l, r] = String.split cond_str, "<"
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 < cell_num)}
      contains?.(">") ->
        [l, r] = String.split cond_str, ">"
        cell_num = if String.contains?(r, "."), do: round(String.to_float(r) / space_step), else: round(String.to_integer(r) / space_step)
        {l, &(&1 > cell_num)}
    end
    cond do
      left == "x" ->
        fn({x, _y}) -> func.(x) end
      left == "y" ->
        fn({_x, y}) -> func.(y) end
    end
  end
end # SolvICFlow.BCInfo
