defmodule Layout do

  require EEx

  EEx.function_from_file :def, :page, 		"priv/templates/page.html.eex", [:head, :nav, :content, :login]
  EEx.function_from_file :def, :alert,		"priv/templates/alert.html.eex", [:level, :message]
  EEx.function_from_file :def, :hint,		"priv/templates/hint_panel.html.eex", [:hint]

  EEx.function_from_file :defp, :head_base,	"priv/templates/head_base.html.eex", [:title]
  EEx.function_from_file :defp, :head_blockly,	"priv/templates/head_blockly.html.eex", []
  EEx.function_from_file :defp, :head_controls,	"priv/templates/head_controls.html.eex", []
  EEx.function_from_file :defp, :navigation, 	"priv/templates/navigation.html.eex", [:controller, :session_message]
  EEx.function_from_file :defp, :login, 	"priv/templates/login.html.eex", []
  EEx.function_from_file :defp, :signup,	"priv/templates/signup.html.eex", []
  EEx.function_from_file :defp, :session_live,	"priv/templates/session_logged_in.html.eex", [:id, :username]
  EEx.function_from_file :defp, :session_dead,	"priv/templates/session_logged_out.html.eex", []

  EEx.function_from_file :def, :blockly,       "priv/templates/editor/blockly.html.eex", []
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
    controls:	false	If the page will include simulation controls
    blockly:	false	If the page will include a blockly editor 
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

    # body
    page(head, navigation, content, extras)
  end









  # TODO: Remove this one
  def page(head, navigation, content) do
    extras = login() <> signup()
    page(head, navigation, content, extras) 
  end

  def head(title, options) do
    html_text = head_base(title)
    head_section(html_text, options)
  end

  def nav(user_id, controller) do
    navigation(controller, user_id)
  end


  defp head_section(text, []) do
    text
  end

  defp head_section(text, [:blockly | tail]) do
    head_section(text <> head_blockly(), tail)
  end

  defp head_section(text, [:controls | tail]) do
    head_section(text <> head_controls(), tail)
  end

  

end
