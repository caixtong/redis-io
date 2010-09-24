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
      by = find(".argument", text: "BY")

      assert by
      assert by.text["pattern"]

      limit = find(".argument", text: "LIMIT")

      assert limit
      assert limit.text["start count"]

      order = find(".argument", text: "ASC")

      assert order
      assert order.text["ASC|DESC"]

      alpha = find(".argument", text: "ALPHA")

      assert alpha
      assert alpha.text["ALPHA"]

      store = find(".argument", text: "STORE")

      assert store
      assert store.text["destination"]
    end
  end
end
