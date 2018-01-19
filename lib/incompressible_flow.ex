defmodule IncompressibleFlow do
  @moduledoc """
  """
  @doc """
  Hello world.

  ## Examples

      iex> IncompressibleFlow.hello
      :world

  """
  @compile [:native, {:hipe, [:verbose, :o3]}]
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

    #NOTE: reserve to move obstacle dynamically (for calc  speed)
    %SolvICFlow.FlowData{bc: boundary_conditions, info: information} = flow_data
    %{:x_size => x_size, :y_size => y_size} = information
    u_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:u]
    v_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:v]
    p_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:p]

    solvFlowRecurse 0, flow_data, max_ite_times, {u_bc_field, v_bc_field, p_bc_field}
  end
  defp solvFlowRecurse ite_times, flow_data, max_ite_times, bc_fields do
    #NOTE: this functin's flow is a bit strange for tail recursion
    if ite_times < max_ite_times do
      IO.puts "(F) #{round(ite_times / max_ite_times * 100)}% #{inspect DateTime.utc_now}"
      {result, new_flow_data} = try do
                                  {true, solvFlowStep(flow_data, bc_fields)}
                                rescue
                                  err_msg ->
                                    IO.inspect err_msg
                                  {false, nil}
                                end
      if result do
        solvFlowRecurse ite_times+1, new_flow_data, max_ite_times, bc_fields
      else
        {:error, ite_times, flow_data}
      end
    else
      {:ok, max_ite_times, flow_data}
    end
  end

  defp solvFlowStep flow_data, {u_bc_field, v_bc_field, p_bc_field} do
    flow_data
    |> SolvICFlow.Velocity.update({u_bc_field, v_bc_field})
    |> SolvICFlow.Pressure.update(p_bc_field)
    |> SolvICFlow.Output.emitFlowData
  end

  def testMain do
    output_callbcack_fn = fn({simbol, data}) ->
      case simbol do
        :ok ->
          IO.puts "[Info] current data."
          SolvICFlow.Output.sampleCallbackImpl data, {400, 200}, 20
        :error ->
          IO.puts "[Error] emitError is called."
          IO.inspect data
      end end
    start_time = DateTime.utc_now
    {status, ite_times, flow_data} = IncompressibleFlow.main %{
      :parameter => %{:width => 40,
                      :height => 20,
                      :space_step => 0.1,
                      :CFL_number => 0.2,
                      :init_velocity => [1, 0],
                      :init_pressure => 1,
                      :Re => 50,
                      :bc_strings => ["u=1;x=0", "u=0;x>=4,x<=4,y>=4,y<=8", "v=0;x>=4,x<=8,y>=4,y<=8"]},
      :calc_info => %{:max_ite_times => 500}}, output_callbcack_fn
    
    end_time = DateTime.utc_now
    :timer.sleep 3000
    IO.inspect flow_data
    IO.inspect status
    IO.inspect ite_times
    IO.puts "start time: #{inspect start_time}"
    IO.puts "finish time: #{inspect end_time}"
  end


end # IncompressibleFlow
