defmodule QuWeb.LoginLive do
  use QuWeb, :live_view

  import Plug.Conn, only: [put_session: 3]

  @impl true
  def render(assigns) do
    ~H"""
    <form phx-submit="save">
      <.input id="username" name="username" type="text" label="Username" value="" />

      <.button phx-disable-with="Saving...">Submit</.button>
    </form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"username" => username}, socket) do
    {:noreply, socket |> put_session(:username, username) |> redirect(~p"/")}
  end
end
