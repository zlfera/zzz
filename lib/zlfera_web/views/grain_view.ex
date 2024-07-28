defmodule ZlferaWeb.GrainView do
  use ZlferaWeb, :html

  def dizeng(pid) do
    Agent.update(pid, fn i -> i + 1 end)
    Agent.get(pid, fn i -> i end)
  end
end
