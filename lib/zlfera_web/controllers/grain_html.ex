defmodule ZlferaWeb.GrainHtml do
  use ZlferaWeb, :html

  def dizeng(pid) do
    Agent.update(pid, fn i -> i + 1 end)
    Agent.get(pid, fn i -> i end)
  end

  embed_templates "grain_html/*"
end
