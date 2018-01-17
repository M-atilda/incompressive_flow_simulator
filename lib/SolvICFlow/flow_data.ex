#file   flow.ex
#author mi-na
#date   18/01/15

defmodule SolvICFlow.FlowData do
  #struct FlowData
  #brief  all information about flow's (and filed's) status
  #! u [[float]]
  #! v
  #! w
  #! p
  #! boundary_info %{:u => [%BCInfo], ...}
  #! info %{}
  defstruct u: [], v: [], p: [], bc: nil, info: nil
end # SolvICFlow.FlowData
