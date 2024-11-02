defmodule QuWeb.EnqueueLive do
  use QuWeb, :live_view

  on_mount {QuWeb.UserLiveAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="queue" phx-update="stream">
      <p :for={{item_id, user} <- @streams.queue} id={item_id}>
        <%= user.name %>
      </p>
    </div>

    <span :if={is_nil(@position)}>
      <.button phx-click="join_list">Join list</.button>
    </span>
    <span :if={@position}>
      You are the in the <%= @position + 1 %>º position
    </span>

    <.button
      id="notification-permission"
      phx-hook="RequestNotificationPermission"
      phx-click="request_notification_permission"
    >
      Request notification permission
    </.button>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Qu.PubSub, "queue")
    end

    {:ok,
     socket
     |> stream_configure(:queue, dom_id: &"user-#{&1.name}")
     |> update_queue(Qu.Queue.get())}
  end

  @impl true
  def handle_event("join_list", _params, socket) do
    user = socket.assigns.current_user
    Qu.Queue.push(user)
    {:noreply, stream_insert(socket, :queue, user, limit: -10)}
  end

  def handle_event("request_notification_permission", _params, socket) do
    {:noreply, push_event(socket, "request-notification-permission", %{})}
  end

  @impl true
  def handle_info({:change, queue}, socket) do
    {:noreply,
     socket
     |> update_queue(queue)
     |> send_notification()}
  end

  defp update_queue(socket, queue) do
    socket
    |> stream(:queue, Enum.take(queue, 10), reset: true)
    |> assign(:position, Enum.find_index(queue, &(&1 == socket.assigns.current_user)))
  end

  defp send_notification(socket) do
    case socket.assigns.position do
      0 -> push_event(socket, "notification", %{title: "It is your turn now!"})
      1 -> push_event(socket, "notification", %{title: "You are the next!", body: "Get ready!"})
      _n -> socket
    end
  end
end
