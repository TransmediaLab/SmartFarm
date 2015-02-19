defmodule SmartfarmServer do
  @behaviour :application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {'/weather.html', :cowboy_static, {:priv_file, :smartfarm, <<"weather.html">>}},
        {'/font/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"font">>}},
        {'/css/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"css">>}},
        {'/js/[...]', :cowboy_static, {:priv_dir, :smartfarm, <<"js">>}},
        {'/ws',  FileHandler, []},
        {'/_ws', WebSocketHandler, [{:dumb_protocol,   DumbIncrementHandler},
                                    {:mirror_protocol, MirrorHandler},
                                    {:weather_protocol, WeatherHandler},
                                    {:plant_protocol, PlantHandler}]},
        {'/',    HelloHandler, []}
      ]}
    ])
    :cowboy.start_http :my_http_listener, 100, [{:port, 80}], [{:env, [{:dispatch, dispatch}]}]
    IO.puts "Started listening on port 80..."

    WebSocketSup.start_link
  end

  def stop(_state) do
    :ok
  end
end