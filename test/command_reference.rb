require "./test/helper"

scope do
  test "Command reference" do
    visit "/commands"

    assert has_content?("ECHO")
  end

  test "Command page" do
    visit "/commands"

    click "EXPIREAT"

    assert has_css?("title", text: "EXPIREAT")

    within "h1" do
      assert has_content?("EXPIREAT")
      assert has_content?("key")
      assert has_content?("timestamp")
    end

    within "article" do
      assert has_css?("p", text: "Set a timeout on the specified key.")
      assert has_content?("Available since 1.1")
    end
  end

  test "Command page with complex arguments" do
    visit "/commands"

    click "SORT"

    within "h1" do
      assert has_content?("[BY pattern]")
      assert has_content?("[LIMIT start count]")
      assert has_content?("[ASC|DESC]")
      assert has_content?("[ALPHA]")
      assert has_content?("[STORE destination]")
    end
  end
end
