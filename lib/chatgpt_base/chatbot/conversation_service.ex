defmodule ChatgptBase.Chatbot.ConversationService do
  use GenServer

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @doc """
  Sends a new message to the conversation
  """
  @spec add_user_message(pid, String.t()) :: %{}
  def add_user_message(pid, message) do
    GenServer.call(pid, {:add_user_message, message})
  end

  @spec get_response(pid) :: %{}
  def get_response(pid) do
    GenServer.call(pid, :get_response)
  end

  @spec get_messages(pid) :: %{}
  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  # Server
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call({:add_user_message, message}, _from, messages) do
    messages = messages ++ [%{"role" => "user", "content" => message}]
    {:reply, messages, messages}
  end

  @impl true
  def handle_call(:get_response, _from, messages) do
    response = ChatgptBase.Chatbot.OpenAiClient.call(messages)
    messages = messages ++ [response]
    {:reply, messages, messages}
  end

  @impl true
  def handle_call(:get_messages, _from, messages) do
    {:reply, messages, messages}
  end
end
