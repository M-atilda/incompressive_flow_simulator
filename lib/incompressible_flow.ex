defmodule IncompressibleFlow do
  @moduledoc """
  """
  @doc """
  Hello world.

  ## Examples

      iex> IncompressibleFlow.hello
      :world

  """


  defmodule IncompressiveFlow.FlowData do
    #struct FlowData
    #brief  all information about flow's (and filed's) status
    #! u [[float]]
    #! v
    #! w
    #! p
    #! boundary_info %{:u => [%BCInfo], ...}
    #! info %{}
    defstruct u: [], v: [], w: [], p: [], bc: nil, info: nil
  end # FlowData

  def main solve_info, output_callbcack do
    SolvICFlow.Output.initOServer output_callbcack
    solvFlow solve_info
  end
  
  #fn solvFlow(json)
  #! args %{:parameter => %{}, :calc_info => %{}}
  defp solvFlow %{:parameter => parameter,
                  :calc_info => %{:situation => situation,
                                  :v_calc_info => v_calc_info,
                                  :p_calc_info => p_calc_info}} do
    flow_data = SolvICFlow.Init.genFlow parameter
    solve_routine_fn = fn(ite_times, flow_data) ->
      #NOTE: this functin is a bit complicated for tail recursion
      if ite_times < situation[:max_ite_times] do
        {result, new_flow_data} = try do
                                    {true, solvStepFlow(v_calc_info, p_calc_info, flow_data)}
                                  rescue
                                    _ -> {false, nil}
                                  end
        if result do
          solve_routine_fn ite_times+1, new_flow_data
        else
          {ite_times, flow_data}
        end
      else
        {ite_times, flow_data}
      end
    end
    solve_routine_fn 0, flow_data
  end

  defp solvStepFlow flow_data do
    flow_data
    |> SolvICFlow.Velocity.update
    |> SolvICFlow.Pressure.update
    |> SolvICFlow.Output.emitFlowData
  end


end # IncompressiveFlow

alias IncompressibleFlow.FlowData, as: tagFlowData
