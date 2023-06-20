defmodule ChatgptBaseWeb.ChatBotLive do
  use Phoenix.LiveView

  alias ChatgptBase.Chatbot.ConversationService

  @impl true
  def mount(_params, _session, socket) do
    # For this tutorial, we are only working with a single conversation
    {:ok, conversation} = ChatgptBase.Chatbot.ConversationService.start_link([])

    {
      :ok,
      socket
      |> assign(:conversation, conversation)
      |> assign(:messages, [])
    }
  end

  @impl true
  def handle_info({ChatgptBaseWeb.Live.FormComponent, {:saved, message}}, socket) do
    conversation = socket.assigns.conversation

    ConversationService.add_user_message(conversation, message)

    Task.async(fn ->
      ConversationService.get_response(conversation)
    end)

    messages = ConversationService.get_messages(conversation)

    {
      :noreply,
      socket
      |> assign(:messages, messages)
    }
  end

  def handle_info({ref, messages}, socket) do
    Process.demonitor(ref, [:flush])

    {
      :noreply,
      socket
      |> assign(:messages, messages)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col flex-grow w-full bg-white shadow-xl rounded-t-lg overflow-hidden">
      <div class="flex flex-col flex-grow p-4 overflow-auto max-h-full">
        <div class="flex w-full mt-2 space-x-3 max-w-xs">
          <img
            class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"
            src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.nedap-livestockmanagement.com%2Fwp-content%2Fuploads%2F2017%2F02%2FMake-your-farm-future-proof-thumb-1280x1124.jpg&f=1&nofb=1&ipt=8d999efe4ffa37c42658b2aaa0eeca133a5b77ce97fbced6c812c3bc1ad44416&ipo=images"
            alt=""
          />
          <div>
            <div class="bg-gray-300 p-3 rounded-r-lg rounded-bl-lg">
              <p class="text-sm">Hi. I am here to answer questions about Elixir.</p>
            </div>
            <span class="text-xs text-gray-500 leading-none">Now</span>
          </div>
        </div>
        <%= for message <- @messages do %>
          <div>
            <div
              :if={message["role"] == "user"}
              class="flex w-full mt-2 space-x-3 max-w-xs ml-auto justify-end"
            >
              <div>
                <div class="bg-blue-600 text-white p-3 rounded-l-lg rounded-br-lg">
                  <p class="text-sm"><%= message["content"] %></p>
                </div>
                <span class="text-xs text-gray-500 leading-none">Now</span>
              </div>
              <img
                class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"
                src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse3.mm.bing.net%2Fth%3Fid%3DOIP.L8VSGT6cPiUFpzMCxJv28gHaHa%26pid%3DApi&f=1&ipt=af0a3eb5169f343cfb029353bafe5e4bf25273926a85184a68780bbeef3e3b83&ipo=images"
                alt=""
              />
            </div>

            <div :if={message["role"] == "assistant"} class="flex w-full mt-2 space-x-3 max-w-xs">
              <img
                class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"
                src="https://images.unsplash.com/photo-1589254065878-42c9da997008?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                alt=""
              />
              <div>
                <div class="bg-gray-300 p-3 rounded-r-lg rounded-bl-lg">
                  <p class="text-sm"><%= message["content"] %></p>
                </div>
                <span class="text-xs text-gray-500 leading-none">Now</span>
              </div>
            </div>
          </div>
        <% end %>
      </div>

      <div class="bg-gray-300 p-4">
        <.live_component
          module={ChatgptBaseWeb.Live.FormComponent}
          id="new-message"
          conversation={@conversation}
        />
      </div>
    </div>
    """
  end
end
