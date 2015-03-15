defmodule SmartfarmServer do
  @behaviour :application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {'/weather.html', :cowboy_static, {:priv_file, :smartfarm, <<"weather.html">>}},
        {'/font/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"font">>}},
        {'/css/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"css">>}},
        {'/js/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"js">>}},
        {'/media/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"media">>}},
        {'/ws',  FileHandler, []},
        {'/login', LoginHandler, []},
        {'/logout', LogoutHandler, []},
        {'/signup', SignupHandler, []},
        {'/weather[/:id]', WeatherHandler, []},
        {'/weather/:id/ws', WeatherWebSocketHandler, []},
        {'/plants[/:id]', PlantHandler, []},
        {'/plants/:id/ws', PlantWebSocketHandler, []},
        {'/farms[/:id]', FarmHandler, []},
        {'/farms/:id/ws', FarmWebSocketHandler, []},
        {'/simulations[/:id]', SimulationHandler, []},
        {'/simulation_ws', SimulationWebSocketHandler, []},
        {'/',    HelloHandler, []}
      ]}
    ])
    :cowboy.start_http :my_http_listener, 100, [{:port, 80}], [{:env, [{:dispatch, dispatch}]}]
    IO.puts "Started listening on port 80..."

    Database.init

    WebSocketSup.start_link
  end

  def stop(_state) do
    :ok
  end
end
