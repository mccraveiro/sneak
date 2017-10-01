defmodule Sneak.Worker do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(args) do
    IO.puts "Worker - started"
    spawn(&get_url/0)
    {:ok, args}
  end

  def handle_info(:get_url, state) do
    spawn(&get_url/0)
    {:noreply, state}
  end

  defp get_url do
    url = Sneak.Storage.pop()
    crawl(url)
  end

  defp crawl(nil) do
    IO.puts "Worker - storage is empty. Trying again in 1s"
    Process.send_after(__MODULE__, :get_url, 1_000)
  end

  defp crawl(url) do
    IO.puts "Worker - Crawling url: " <> url
    url
    |> get_html
    |> get_next_pages(url)
    |> get_product(url)
    |> IO.inspect

    Process.send_after(__MODULE__, :get_url, 1_000)
  end

  defp get_html(url) do
    response = HTTPoison.get! url
    response.body
  end

  defp get_next_pages(html, base_url) do
    Floki.find(html, "a")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> normalize_url(base_url, url) end)
    |> Enum.filter(fn(x) -> x != "" end)
    |> Enum.map(fn(url) -> Sneak.Storage.push(url) end)

    html
  end

  defp prefix_url(base_url, url) do
    case url do
      "http" <> _       -> url
      "//" <> _         -> "https:" <> url
      "/" <> _          -> "https://www.magazineluiza.com.br" <> url
      "javascript" <> _ -> ""
      "mailto:" <> _    -> ""
      _                 -> base_url <> url
    end
  end

  defp normalize_url(base_url, url) do
    prefix_url(base_url, url)
    |> String.split(["#", "?"])
    |> Enum.at(0)
  end

  defp get_product(html, url) do
    title = get_product_title(html)
    price = get_product_price(html)

    %{ url: url, title: title, price: price }
  end

  defp get_product_title(html) do
    Floki.find(html, ".header-product__title")
    |> Floki.text
  end

  defp get_product_price(html) do
    Floki.find(html, ".price-template__text")
    |> Floki.text
  end
end
