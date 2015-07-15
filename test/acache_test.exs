defmodule AcacheTest do
  use ExUnit.Case

  test "test cache" do
  	#
  	#	test serializer
  	#
    :ok = Acache.init(:bug, %{value: [], serializer: :json})
    :ok = Acache.cast(:bug, &([1|&1]))
    :ok = Acache.cast(:bug, &([2|&1]))
    %Acache.State{raw: [1,2,3], serialized: "[1,2,3]"} = Acache.call(:bug, &([3|&1] |> Enum.sort))
    "[1,2,3]" = Acache.get(:bug)
    #
    #	not serialize if it not needed
    #
    :ok = Acache.init(:buf, %{value: [], serializer: &(IO.inspect(&1))})
    :ok = Acache.cast(:buf, &([1|&1] |> Enum.sort))
    :ok = Acache.cast(:buf, &(&1))
    :ok = Acache.cast(:buf, &([2|&1] |> Enum.sort))
    :ok = Acache.cast(:buf, &(&1))
    :ok = Acache.cast(:buf, &([3|&1] |> Enum.sort))
    :ok = Acache.cast(:buf, &(&1))
    :ok = Acache.cast(:buf, &(&1))
    :ok = Acache.cast(:buf, &(&1))
    %Acache.State{raw: [1,2,3], serialized: [1,2,3]}  = Acache.call(:buf, &(&1))
    [1,2,3] = Acache.get(:buf)
    #
    #	test force serializer
    #
    :ok = Acache.force_serialize_cast(:buf)
    %Acache.State{raw: [1,2,3], serialized: [1,2,3]}  = Acache.force_serialize_call(:buf)
    [1,2,3] = Acache.get(:buf)
  end
end
