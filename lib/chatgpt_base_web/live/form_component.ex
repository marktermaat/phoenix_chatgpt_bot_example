defmodule ChatgptBaseWeb.Live.FormComponent do
  use ChatgptBaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="message-form" phx-target={@myself} phx-change="change" phx-submit="save">
        <.input field={@form[:content]} value={@content} type="text" placeholder="Type your message" />
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:content, "")
     |> assign(:form, to_form(%{}))}
  end

  @impl true
  # def handle_event("change", %{"message" => %{"content" => content}}, socket) do
  def handle_event("change", %{"content" => content}, socket) do
    {:noreply, assign(socket, :content, content)}
  end

  @impl true
  def handle_event("save", %{"content" => message}, socket) do
    notify_parent({:saved, message})
    {:noreply, assign(socket, :content, "")}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
