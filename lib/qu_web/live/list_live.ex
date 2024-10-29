defmodule QuWeb.ListLive do
  use QuWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div id="queue" phx-update="stream">
      <p :for={{item_id, name} <- @streams.queue} id={item_id}>
        <%= name %>
      </p>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Qu.PubSub, "queue")
    end

    {:ok,
     socket
     |> stream_configure(:queue, dom_id: &"name-#{&1}")
     |> stream(:queue, Qu.Queue.peek(10))}
  end

  @impl true
  def handle_info({:push, _item}, socket) do
    {:noreply, stream(socket, :queue, Qu.Queue.peek(10), reset: true)}
  end
end
