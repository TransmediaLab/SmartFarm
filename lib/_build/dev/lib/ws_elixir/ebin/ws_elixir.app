{application,ws_elixir,
             [{registered,[]},
              {description,"ws_elixir"},
              {applications,[kernel,stdlib,elixir,ranch,crypto,cowboy,gproc]},
              {mod,{'Elixir.WebSocketServer',[]}},
              {vsn,"0.1.0"},
              {modules,['Elixir.DumbIncrementHandler','Elixir.FileHandler',
                        'Elixir.HelloHandler','Elixir.MirrorHandler',
                        'Elixir.WebSocketHandler','Elixir.WebSocketServer',
                        'Elixir.WebSocketSup']}]}.