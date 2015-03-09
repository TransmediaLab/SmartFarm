defmodule Layout do

  require EEx

  # private html rendering API
  EEx.function_from_file :defp, :page,		"priv/templates/page.html.eex", [:head, :navigation, :content, :extras]
  EEx.function_from_file :defp, :head_base,	"priv/templates/head_base.html.eex", [:title]
  EEx.function_from_file :defp, :head_blockly,	"priv/templates/head_blockly.html.eex", []
  EEx.function_from_file :defp, :head_controls,	"priv/templates/head_controls.html.eex", []
  EEx.function_from_file :defp, :head_maps,	"priv/templates/head_maps.html.eex", []
  EEx.function_from_file :defp, :navigation, 	"priv/templates/navigation.html.eex", [:controller, :session_message]
  EEx.function_from_file :defp, :login, 	"priv/templates/login.html.eex", []
  EEx.function_from_file :defp, :signup,	"priv/templates/signup.html.eex", []
  EEx.function_from_file :defp, :session_live,	"priv/templates/session_logged_in.html.eex", [:id, :username]
  EEx.function_from_file :defp, :session_dead,	"priv/templates/session_logged_out.html.eex", []

  @doc """
    Renders the provided message as a Bootstrap (http://getbootstrap.com) alert at
    the supplied warning level
  """
  EEx.function_from_file :def, :alert,		"priv/templates/alert.html.eex", [:level, :message]

  @doc """
    Renders the provided hint in a styled Bootstrap (http://getbootstrap.com) HTML panel
  """
  EEx.function_from_file :def, :hint,		"priv/templates/hint_panel.html.eex", [:hint]

  @doc """
    Renders a Blockly editor panel
  """
  EEx.function_from_file :def, :blockly,	"priv/templates/editor/blockly.html.eex", []

  @doc """
    Renders a series of buttons to control a SmartFarm simulation
  """
  EEx.function_from_file :def, :controls,	"priv/templates/editor/controls.html.eex", []

  @doc """ 
    Creates the HTML to serve as a page response, automatically generating
    the head and body, and navigation sections and adding the supplied
    content.  Options that can be specified are:

    options	default		purpose
    title:	""	<a string that will be added to the <title> element of the page
    user_name:	""	The logged-in user's name
    user_id:	nil	The logged-in user's id
    controller:	""	The navigation section related to the current page
    controls:	false	If true the page will include simulation controls
    blockly:	false	If true the page will include a blockly editor 
    maps: 	false	If true the page will include google maps api
    scripts: 	[]	Array of paths to additional JavaScript script files to load
  """
  def page(content, options) do

    # head
    head = head_base(Keyword.get options, :title, <<"">>)
    if Keyword.get(options, :blockly, false) do 
      head = head <> head_blockly()
    end
    if Keyword.get(options, :controls, false) do
      head = head <> head_controls()
    end
    if Keyword.get(options, :maps, false) do
      head = head <> head_maps()
    end
    scripts = Keyword.get(options, :scripts, []) 
    head = head <> script_tags("", scripts)

    # navigation
    controller = Keyword.get(options, :controller, :undefined)
    user_id = Keyword.get(options, :user_id, nil)
    if user_id do
      user_name = User.username(user_id)
      navigation = navigation(controller, session_live(user_id, user_name))
    else
      navigation = navigation(controller, session_dead())
    end

    # extras
    extras = login() <> signup()

    # data
    data = Keyword.get(options, :data, false)
    if data do
      extras = extras <> "<script type='text/javascript'>var data=#{data}</script>"
    end

    # body
    page(head, navigation, content, extras)

  end

  # Generates a script tag from a list of script paths
  defp script_tags(acc, []) do
    acc
  end

  defp script_tags(acc, [head|tail]) do
    acc = "<script type='text/javascript' src='#{head}'></script>" <> acc
    script_tags(acc, tail)
  end

end
