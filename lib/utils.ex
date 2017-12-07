defmodule HashRing.Utils do
  @compile :native

  @spec hash(atom | binary | integer) :: integer
  def hash(key) when is_binary(key) do
    <<_ :: binary-size(8), value :: unsigned-little-integer-size(64)>> = :erlang.md5(key)
    value
  end
  def hash(key), do: hash("#{key}")

  @spec gen_items(binary, integer) :: [{integer, binary}]
  def gen_items([], _num_replicas), do: []
  def gen_items(nodes, num_replicas) do
    gen_items(nodes, Enum.to_list(0..(num_replicas - 1)), [])
  end

  defp gen_items([], _replicas, items) do
    Enum.sort(items, &(elem(&1, 0) < elem(&2, 0)))
  end
  defp gen_items([node|nodes], replicas, items) do
    items = Enum.reduce(replicas, items, &([{hash("#{node}#{&1}"), node}|&2]))
    gen_items(nodes, replicas, items)
  end
end