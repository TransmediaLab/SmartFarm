defmodule LayoutTest do
  use ExUnit.Case

  #TODO: Tests would be far less brittle with HTML parsing
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  test "Layout.alert should render a Bootstrap alert containing the supplied message at the indicated level of severity" do
    html = Layout.alert <<"success">>, <<"Success!">>
    assert String.contains? html, "class='alert alert-success'"
    assert String.contains? html, "Success!"

    html = Layout.alert <<"info">>, <<"Welcome neighbor">>
    assert String.contains? html, "class='alert alert-info'"
    assert String.contains? html, "Welcome neighbor"

    html = Layout.alert <<"warning">>, <<"This is a warning">>
    assert String.contains? html, "class='alert alert-warning'"
    assert String.contains? html, "This is a warning"

    html = Layout.alert <<"danger">>, <<"Danger, Will Robinson!">>
    assert String.contains? html, "class='alert alert-danger'"
    assert String.contains? html, "Danger, Will Robinson!"
  end

  test "Layout.hint should render a panel containing the supplied hint" do
    html = Layout.hint <<"The cake is a lie">>
    assert String.contains? html, "The cake is a lie"
  end

  test "Layout.blockly should render a div with id of blocklyDiv" do
    html = Layout.blockly
  end

  test "Layout.controls should render a series of buttons to control a SmartFarm simulation" do
    html = Layout.controls
  end

  
  """
    Creates the HTML to serve as a page response, automatically generating
    the head and body, and navigation sections and adding the supplied
    content.  Options that can be specified are:

    options     default         purpose
    title:      ""      <a string that will be added to the <title> element of the page
    user_name:  ""      The logged-in user's name
    user_id:    nil     The logged-in user's id
    controller: ""      The navigation section related to the current page
    controls:   false   If the page will include simulation controls
    blockly:    false   If the page will include a blockly editor
  """  
  test "Layout.page should generate a valid HTML page contianing content with options(content, options)" do
  end


end
