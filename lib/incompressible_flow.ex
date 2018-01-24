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


  def main name, solve_info, output_callbcack do
    SolvICFlow.Output.genOServer name, output_callbcack
    solvFlow name, solve_info
  end

  #fn solvFlow(json)
  #! args %{:parameter => %{}, :calc_info => %{}}
  defp solvFlow name, %{:parameter => parameter,
                        :calc_info => %{:max_ite_times => max_ite_times}} do
    flow_data = SolvICFlow.Init.genFlow parameter

    #NOTE: reserve to move obstacle dynamically (for calc  speed)
    %SolvICFlow.FlowData{bc: boundary_conditions, info: information} = flow_data
    %{:x_size => x_size, :y_size => y_size} = information
    u_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:u]
    v_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:v]
    p_bc_field = SolvICFlow.BCInfo.genBCField {x_size, y_size}, boundary_conditions[:p]

    solvFlowRecurse name, 0, flow_data, max_ite_times, {u_bc_field, v_bc_field, p_bc_field}
  end
  defp solvFlowRecurse name, ite_times, flow_data, max_ite_times, bc_fields do
    #NOTE: this functin's flow is a bit strange for tail recursion
    if ite_times < max_ite_times do
      IO.puts "(F) #{round(ite_times / max_ite_times * 100)}% #{inspect DateTime.utc_now}"
      {result, new_flow_data} = try do
                                  {true, solvFlowStep(name, flow_data, bc_fields)}
                                rescue
                                  err ->
                                    IO.inspect err
                                    SolvICFlow.Output.emitError name, inspect(err)
                                  
                                  {false, nil}
                                end
      if result do
        solvFlowRecurse name, ite_times+1, new_flow_data, max_ite_times, bc_fields
      else
        {:error, ite_times, flow_data}
      end
    else
      {:ok, max_ite_times, flow_data}
    end
  end

  defp solvFlowStep name, flow_data, {u_bc_field, v_bc_field, p_bc_field} do
    flow_data
    |> SolvICFlow.Velocity.update({u_bc_field, v_bc_field}, name)
    |> SolvICFlow.Pressure.update(p_bc_field, name)
    |> SolvICFlow.Output.emitFlowData(name)
  end

  def testMain do
    CalcPServer.genCalcServer "test", %{:max_ite_times => 100,
                                        :error_p => 0.0001,
                                        :omega => 1,
                                        :max_res_ratio => 0.5}
    CalcVServer.genCalcServer "test", :u
    CalcVServer.genCalcServer "test", :v
    output_callbcack_fn = SolvICFlow.Result.genJsonOutputCallback "test", "result"
    {status, ite_times, flow_data} = IncompressibleFlow.main "test", %{
      :parameter => %{:width => 40,
                      :height => 20,
                      :space_step => 0.1,
                      :CFL_number => 0.1,
                      :init_velocity => {1.0, 0.0},
                      :init_pressure => 1.0,
                      :Re => 50,
                      :bc_strings => ["u=1.0;x=0", "u=0.0;x>=12,x<=16,y>=12,y<=16", "v=0.0;x>=12,x<=16,y>=12,y<=16"]},
      :calc_info => %{:max_ite_times => 8000}}, output_callbcack_fn

    waitUntilFinish
    :timer.sleep 3000
    
    IO.puts ""
    IO.inspect status
    IO.inspect ite_times
  end

  def waitUntilFinish do
    if SolvICFlow.Result.hasFinished?("test") do
      true
    else
      IO.puts "[Info] waiting for dumping the results... #{inspect DateTime.utc_now}"
      :timer.sleep 3600000
      waitUntilFinish
    end
  end

  def genResultBuilder name, path do
    SolvICFlow.Result.genRBuilder name, path
  end


end # IncompressibleFlow
