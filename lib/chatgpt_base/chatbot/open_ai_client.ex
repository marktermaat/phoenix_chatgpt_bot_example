defmodule ChatgptBase.Chatbot.OpenAiClient do
  defp default_system_prompt do
    """
    You are a chatbot that will try to answer questions.
    """
  end

  @spec call([%{String.t => String.t}]) :: %{String.t => String.t}
  def call(prompts, opts \\ []) do
    %{
      "model" => "gpt-3.5-turbo",
      "messages" =>
        Enum.concat(
          [
            %{"role" => "system", "content" => default_system_prompt()}
          ],
          prompts
        ),
      "temperature" => 0.7
    }
    |> Jason.encode!()
    |> request(opts)
    |> parse_response()
  end

  defp parse_response({:ok, %Finch.Response{body: body}}) do
    messages =
      Jason.decode!(body)
      |> Map.get("choices", [])
      |> Enum.reverse()

    case messages do
      [%{"message" => message} | _] -> message
      _ -> "{}"
    end
  end

  defp parse_response(error) do
    error
  end

  defp request(body, _opts) do
    Finch.build(:post, "https://api.openai.com/v1/chat/completions", headers(), body)
    |> Finch.request(ChatgptBase.Finch)
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Application.get_env(:chatgpt_base, :open_ai_api_key)}"}
    ]
  end
end
