defmodule IncompressibleFlowTest do
  use ExUnit.Case
  doctest IncompressibleFlow

  test "main routine" do
    output_callbcack_fn = fn({simbol, data}) ->
      case simbol do
        :ok ->
          IO.inspect data
        :error ->
          IO.puts data
      end end
    IncompressibleFlow.main %{:parameter => %{:width => 1,
                                              :height => 1,
                                              :depth => 1,
                                              :space_step => 0.1,
                                              :CFL_number => 0.2,
                                              :init_velocity => [1, 0, 0],
                                              :init_pressure => 1,
                                              :Re => 50,
                                              :bc_strings => ["u=0;x=1"]},
                              :calc_info => %{:max_ite_times => 10}}, output_callbcack_fn
  end
end
