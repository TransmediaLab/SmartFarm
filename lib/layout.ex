defmodule Layout do

  require EEx

  EEx.function_from_file :def, :page, "priv/templates/page.html.eex", [:head, :nav, :content, :login]
  EEx.function_from_file :def, :alert,		"priv/templates/alert.html.eex", [:level, :message]

  EEx.function_from_file :defp, :head_base,	"priv/templates/head_base.html.eex", [:title]
  EEx.function_from_file :defp, :head_blockly,	"priv/templates/head_blockly.html.eex", []
  EEx.function_from_file :defp, :head_controls,	"priv/templates/head_controls.html.eex", []
  EEx.function_from_file :defp, :navigation, 	"priv/templates/navigation.html.eex", [:controller]
  EEx.function_from_file :defp, :login, 	"priv/templates/login.html.eex", []
  EEx.function_from_file :defp, :signup,	"priv/templates/signup.html.eex", []

  def page(head, navigation, content) do
    extras = login() <> signup()
    page(head, navigation, content, extras) 
  end

  def head(title, options) do
    html_text = head_base(title)
    head_section(html_text, options)
  end

  def nav(controller) do
    navigation(controller)
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
