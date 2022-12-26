defmodule BlogWeb.FeedController do
  use BlogWeb, :controller

  alias Atomex.Entry
  alias Atomex.Feed
  alias Blog.Posts
  alias Blog.Posts.Article

  def index(conn, _params) do
    articles = Posts.list_articles()
    feed = build_feed(conn, articles)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, feed)
  end

  def build_feed(conn, articles) do
    home_url = Routes.article_index_url(conn, :index)

    Feed.new(home_url, DateTime.utc_now(), "Thiago Ramos / thiagoramos.me")
    |> Feed.author("Thiago Ramos", email: "thiagoramos.al@gmail.com")
    |> Feed.link(BlogWeb.Endpoint.url(), rel: "self")
    |> Feed.entries(Enum.map(articles, &get_entry(&1, home_url)))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp get_entry(
         %Article{html_body: html_body, summary: summary, title: title, slug: slug, date: date},
         url
       ) do
    Entry.new(
      "#{url}articles/#{slug}",
      DateTime.new!(date, ~T[00:00:00]),
      title
    )
    |> Entry.author("Thiago Ramos", uri: "#{url}about")
    |> Entry.add_field(:summary, %{}, summary)
    |> Entry.content(html_body, type: "html")
    |> Entry.build()
  end
end
