defmodule Sneak do
  def start() do
    base_url = "http://www.magazineluiza.com.br"
    Sneak.Storage.start(base_url)
    Sneak.Worker.start()
  end
end
