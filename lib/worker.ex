defmodule Acache.Worker do
	use ExActor.GenServer
	use Silverb
	definit(some = %{name: name}) do
		case Acache.Tinca.get(name) do
			old = %Acache.State{} -> {:ok, old}
			nil -> {:ok, some |> store}
		end
	end
	defcast cast(handler), when: is_function(handler,1), state: state do
		{:noreply, Map.update!(state, :value, handler) |> store}
	end
	defcast force_serialize_cast, state: state do
		{:noreply, store_proc(state)}
	end
	defcall call(handler), when: is_function(handler,1), state: state = %{name: name} do
		new_state = Map.update!(state, :value, handler) |> store
		{:reply, Acache.get_full(name), new_state}
	end
	defcall force_serialize_call, state: state = %{name: name} do
		new_state = store_proc(state)
		{:reply, Acache.get_full(name), new_state}
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