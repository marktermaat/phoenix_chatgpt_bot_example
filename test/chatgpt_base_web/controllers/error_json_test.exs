defmodule ChatgptBaseWeb.ErrorJSONTest do
  use ChatgptBaseWeb.ConnCase, async: true

  test "renders 404" do
    assert ChatgptBaseWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ChatgptBaseWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
