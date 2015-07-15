defmodule Acache.Worker do
	use ExActor.GenServer
	use Silverb
	definit(some) do
		{:ok, some |> store}
	end
	defcast cast(handler), when: is_function(handler,1), state: state do
		{:noreply, Map.update!(state, :value, handler) |> store}
	end
	defcall call(handler), when: is_function(handler,1), state: state do
		new_state = Map.update!(state, :value, handler) |> store
		{:reply, new_state, new_state}
	end
	#
	#	priv
	#
	defp store(args = %{name: name, value: value}) do
		case Acache.Tinca.get(name) do
			%Acache.State{raw: ^value} -> args
			%Acache.State{} -> store_proc(args)
			nil -> store_proc(args)
		end
	end
	defp store_proc(args = %{name: name, value: value, serializer: serializer}) do 
		%Acache.State{raw: value, serialized: serializer.(value)} |> Acache.Tinca.put(name)
		args
	end
end