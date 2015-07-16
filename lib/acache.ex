defmodule Acache do
  use Application
  use Silverb, [{"@actors", :application.get_env(:acache, :actors, nil)}]
  use Tinca, [:__acache__]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Tinca.declare_namespaces
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Acache.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Acache.Supervisor]
    res = Supervisor.start_link(children, opts)
    case @actors do
      nil -> res
      _ -> Enum.each(@actors, fn({namespace, settings}) -> :ok = init(namespace, settings) end); res
    end
  end
  #
  # public
  #
  def init(namespace, %{value: value, serializer: serializer}) when ((is_function(serializer,1) or (serializer in [:none, :json])) and is_atom(namespace)) do
    case exist?(namespace) do
      true -> raise "#{__MODULE__} : can't start, ets table #{namespace} is already exist! Or actor #{namespace} is already exist!"
      false -> true = (namespace == :ets.new(namespace, [:public, :named_table, :ordered_set, {:write_concurrency, true}, {:read_concurrency, true}, :protected]))
               {:ok, pid} = :supervisor.start_child(Acache.Supervisor, Supervisor.Spec.worker(Acache.Worker, [%{name: namespace, value: value, serializer: get_serializer(serializer)}], [id: to_string(namespace)]))
               true = :erlang.register(namespace, pid)
               :ok
    end
  end
  def exist?(namespace), do: (:erlang.whereis(namespace) != :undefined) and (:ets.info(namespace) != :undefined)
  def cast(namespace, handler), do: Acache.Worker.cast(namespace, handler)
  def call(namespace, handler), do: Acache.Worker.call(namespace, handler)
  def force_serialize_cast(namespace), do: Acache.Worker.force_serialize_cast(namespace)
  def force_serialize_call(namespace), do: Acache.Worker.force_serialize_call(namespace)
  def get(name), do: Acache.Tinca.get(name).serialized
  def get_raw(name), do: Acache.Tinca.get(name).raw
  def get_full(name), do: Acache.Tinca.get(name)
  #
  # priv
  #
  defp get_serializer(:none), do: &(&1)
  defp get_serializer(:json), do: &(Poison.Encoder.encode(&1, []) |> Maybe.maybe_to_string)
  defp get_serializer(func) when is_function(func, 1), do: func
  #
  # structs
  #
  defmodule State do
    defstruct raw: nil,
              serialized: nil
  end
end
