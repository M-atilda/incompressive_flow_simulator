defmodule IncompressibleFlowTest do
  use ExUnit.Case
  doctest IncompressibleFlow
  @tag timeout: 43200000

  test "main routine" do
    CalcPServer.genCalcServer "test", %{:max_ite_times => 100,
                                        :error_p => 0.0001,
                                        :omega => 1,
                                        :max_res_ratio => 0.5}
    CalcVServer.genCalcServer "test", :u
    CalcVServer.genCalcServer "test", :v
    # output_callbcack_fn = fn({simbol, data}) ->
    #   case simbol do
    #     :ok ->
    #       # IO.puts "[Info] current data."
    #       # SolvICFlow.Output.sampleCallbackImpl data, {400, 200}, 20
    #       nil
    #     :error ->
    #       IO.puts "[Error] emitError is called."
    #       IO.inspect data
    #   end end
    SolvICFlow.Result.genRBuilder "test", "result"
    output_callbcack_fn = SolvICFlow.Result.genJsonOutputCallback "test", "result"
    {status, ite_times, flow_data} = IncompressibleFlow.main "test", %{
      :parameter => %{:width => 40,
                      :height => 20,
                      :space_step => 0.05,
                      :CFL_number => 0.2,
                      :init_velocity => {1.0, 0.0},
                      :init_pressure => 0,
                      :Re => 100,
                      :bc_strings => ["u=1.0;x=0", "u=0.0;x>=12,x<=16,y>=12,y<=16", "v=0.0;x>=12,x<=16,y>=12,y<=16"]},
      :calc_info => %{:max_ite_times => 1000}}, output_callbcack_fn

    waitUntilFinish
    :timer.sleep 3000
    
    IO.puts ""
    IO.puts "[Info] final results."
    # IO.inspect flow_data
    IO.inspect status
    IO.inspect ite_times
  end

  def waitUntilFinish do
    if SolvICFlow.Result.hasFinished?("test") do
      true
    else
      IO.puts "[Info] waiting for dumping the results... #{inspect DateTime.utc_now}"
      :timer.sleep 60000
      waitUntilFinish
    end
  end
end
