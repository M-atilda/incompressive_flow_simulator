defmodule IncompressibleFlow do
  @moduledoc """
  """
  @doc """
  Hello world.

  ## Examples

      iex> IncompressibleFlow.hello
      :world

  """
  def hello, do: :world

  def main solve_info, output_callbcack do
    SolvICFlow.Output.initOServer output_callbcack
    solvFlow solve_info
  end
  
  #fn solvFlow(json)
  #! args %{:parameter => %{}, :calc_info => %{}}
  defp solvFlow %{:parameter => parameter,
                  :calc_info => %{:max_ite_times => max_ite_times}} do
    flow_data = SolvICFlow.Init.genFlow parameter
    solvFlowRecurse 0, flow_data, max_ite_times
  end
  defp solvFlowRecurse ite_times, flow_data, max_ite_times do
    #NOTE: this functin's flow is a bit strange for tail recursion
    if ite_times < max_ite_times do
      {result, new_flow_data} = try do
                                  {true, solvStepFlow(flow_data)}
                                rescue
                                  _ -> {false, nil}
                                end
      if result do
        solvFlowRecurse ite_times+1, new_flow_data, max_ite_times
      else
        {:error, ite_times, flow_data}
      end
    else
      {:ok, max_ite_times, flow_data}
    end
  end

  defp solvStepFlow flow_data do
    flow_data
    |> SolvICFlow.Velocity.update
    |> SolvICFlow.Pressure.update
    |> SolvICFlow.Output.emitFlowData
  end


end # IncompressibleFlow
