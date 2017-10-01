defmodule Sneak.Storage do
  use GenServer

  def start(base_url) do
    GenServer.start_link(
      __MODULE__,
      %{ base_url: base_url, crawled: [], queue: [base_url]},
      name: __MODULE__
    )
  end

  def push(url) do
    GenServer.cast(__MODULE__, {:push, url})
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  ## GenServer Callbacks
  def init(args) do
    IO.puts "Storage - started"
    IO.inspect args
    {:ok, args}
  end

  def handle_call(:pop, _from, state) do
    IO.puts "Storage - #{length(state.queue)} urls remaining"

    case state.queue do
      [] -> {:reply, nil, state}
      [h | t] -> {
        :reply,
        h,
        Map.merge(state, %{ crawled: [h | state.crawled], queue: t})
      }
    end
  end

  def handle_cast({:push, url}, state) do
    if Enum.member?(state.crawled, url) do
      {:noreply, state}
    else
      {:noreply, Map.merge(state, %{ queue: [url | state.queue]})}
    end
  end
end
