defmodule ChatgptBase.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChatgptBaseWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChatgptBase.PubSub},
      # Start Finch
      {Finch, name: ChatgptBase.Finch},
      # Start the Endpoint (http/https)
      ChatgptBaseWeb.Endpoint
      # Start a worker by calling: ChatgptBase.Worker.start_link(arg)
      # {ChatgptBase.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatgptBase.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatgptBaseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
