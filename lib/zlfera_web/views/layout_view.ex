defmodule ZlferaWeb.LayoutView do
  use ZlferaWeb, :html

  def get_text do
    if File.exists?("./priv/static/index.html") do
      url = "./priv/static/index.html" |> File.read!()
      Jason.decode!(url)
    else
      %{"content" => "", "text_authors" => ""}
    end
  end
end
