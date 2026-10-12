defmodule BlogWeb.AppLiveTest do
  use BlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "visitors can open each app from the collection", %{conn: conn} do
    for {slug, name, url} <- [
          {"for-when", "For When", "https://forwhen.thiagoramos.me"},
          {"todo", "Progress Flow", "https://app.thiagoramos.me"}
        ] do
      {:ok, view, _} = live(conn, "/apps")
      assert has_element?(view, "nav a[aria-current=page]", "Apps")

      assert has_element?(view, "#discover-#{slug}[href='/apps/#{slug}']")
      {:ok, detail, _} = live(conn, "/apps/#{slug}")

      assert has_element?(
               detail,
               "h1",
               if(slug == "todo",
                 do: "A clearer plan for your day.",
                 else: "Good reads. On your time."
               )
             )

      assert has_element?(detail, "a[href='/apps']", "All apps")

      assert length(Floki.find(Floki.parse_fragment!(render(detail)), ".apps-features section")) ==
               3

      assert has_element?(detail, "a[href='#{url}']", "Try #{name}")

      assert has_element?(
               detail,
               "img[src='/images/apps/#{if slug == "todo", do: "todo-home", else: "for-when-reader"}.png']"
             )
    end
  end

  test "Progress Flow uses Home in its hero and shows each page with a description", %{conn: conn} do
    {:ok, view, _} = live(conn, "/apps/todo")
    assert has_element?(view, ".apps-hero-window img[src='/images/apps/todo-home.png']")

    for slug <- ~w(home planning projects project reports summary integrations ai settings) do
      assert has_element?(view, "#tour-#{slug} h3")
      assert has_element?(view, "#tour-#{slug} .apps-description")
      assert has_element?(view, "#tour-#{slug} img[src='/images/apps/todo-#{slug}.png']")
      assert File.regular?(Path.join("priv/static/images/apps", "todo-#{slug}.png"))
    end
  end

  test "For When shows every main view with a screenshot and description", %{conn: conn} do
    {:ok, view, _} = live(conn, "/apps/for-when")

    for slug <- ~w(home reader news sources read favorites archive tags notes) do
      assert has_element?(view, "#tour-#{slug} h3")
      assert has_element?(view, "#tour-#{slug} .apps-description")
      assert has_element?(view, "#tour-#{slug} img[src='/images/apps/for-when-#{slug}.png']")
      assert File.regular?(Path.join("priv/static/images/apps", "for-when-#{slug}.png"))
    end
  end

  test "app pages publish their own share metadata", %{conn: conn} do
    for {path, name} <- [
          {"/apps", "Apps"},
          {"/apps/for-when", "For When"},
          {"/apps/todo", "Progress Flow"}
        ] do
      html = conn |> get(path) |> html_response(200) |> Floki.parse_document!()
      assert Floki.find(html, "title") |> Floki.text() == "#{name} | Apps by Thiago Ramos"

      assert Floki.attribute(html, "link[rel=canonical]", "href") == [
               "https://thiagoramos.me#{path}"
             ]

      assert Floki.attribute(html, "meta[property='og:url']", "content") == [
               "https://thiagoramos.me#{path}"
             ]

      assert Floki.attribute(html, "meta[property='og:description']", "content") ==
               Floki.attribute(html, "meta[name=description]", "content")
    end
  end

  test "shared metadata accepts About's full page URL", %{conn: conn} do
    html = conn |> get("/about") |> html_response(200) |> Floki.parse_document!()

    assert Floki.attribute(html, "meta[property='og:url']", "content") == [
             "https://thiagoramos.me/about"
           ]
  end

  test "unknown apps return not found", %{conn: conn} do
    assert_raise BlogWeb.AppLive.NotFoundError, fn -> get(conn, "/apps/missing") end
  end
end
