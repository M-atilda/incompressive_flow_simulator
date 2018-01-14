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

  def applyBCInfo position, %BCInfo{cond_exp: is_in?, value: val} do
    if is_in?(position) do
      val
    else
      nil
    end
  end
  def genBCField {x_range, y_range, z_range}, boundary_conditions do
    for k <- z_range do
      for j <- y_range do
        for i <- x_range do
          Enum.reduce, boundary_conditions, nil, fn(tag_bc, acm) ->
            if acm != nil do
              acm
            else
              applyBCInfo {i,j,k}, tag_bc
            end
          end
        end end end
  end

  #! bc_info ["u=0;x=0,y=0", ...]
  def genBCInfoMap bc_info do
    keylist = bc_info
    |> Enum.map fn(str) ->
      [val_str, cond_str] = String.split str, ";"
      [kind, val_str] = String.split val_str "="
      {kind, cond_str, String.to_float(val_str)} end
    |> Enum.map fn({kind, cond_str, val}) ->
      {kind, bcInfoFactory(cond_str, val)} end
    extract_bc_fn = fn(kind) ->
      {bcs, _rest} = Keyword.split keylist, [kind]
      bcs end
    Enum.reduce [:u, :v, :w, :p], %{}, fn(kind, acm) ->
      Map.put acm, kind, extract_bc_fn(Atom.to_string(kind)) end
  end
  def bcInfoFactory cond_str, val do
    conds = String.split cond_str, ","
    |> String.replace " ", ""
    |> Enum.map condStr2Exp
    exp = fn(position) ->
      Enum.reduce conds, true, fn(cond, acm) ->
        acm && cond(position) end end
    %IF.BCInfo{cond_exp: exp, value: val}
  end
  defp condStr2Exp cond_str do
    contains? = &(String.contains? cond_str, &1)
    {left, func} = cond do
      contains? "<=" ->
        {l, r} = String.split cond_str, "<="
        {l, &(&1 <= String.to_float(r))}
      contains? ">=" ->
        {l, r} = String.split cond_str, ">="
        {l, &(&1 >= String.to_float(r))}
      contains? "=<" ->
        {l, r} = String.split cond_str, "=<"
        {l, &(&1 <= String.to_float(r))}
      contains? "=>" ->
        {l, r} = String.split cond_str, "=>"
        {l, &(&1 >= String.to_float(r))}
      contains? "=" ->
        {l, r} = String.split cond_str, "="
        {l, &(&1 == String.to_float(r))}
      contains? "<" ->
        {l, r} = String.split cond_str, "<"
        {l, &(&1 < String.to_float(r))}
      contains? ">" ->
        {l, r} = String.split cond_str, ">"
        {l, &(&1 > String.to_float(r))}
    end
    cond do
      left == "x" ->
        fn({x, _y, _z}) -> func(x) end
      left == "y" ->
        fn({_x, y, _z}) -> func(y) end
      left == "z" ->
        fn({_x, _y, z}) -> func(z) end
    end
  end
end # SolvICFlow.BCInfo
