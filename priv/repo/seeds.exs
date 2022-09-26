# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Blog.Posts.Article
alias Blog.Repo

file_string =
  "priv/posts/post.html.md"
  |> File.read!()
  |> String.split("\n")

[title, summary] =
  file_string
  |> Enum.take(2)

markdown = file_string |> Enum.drop(2) |> Earmark.as_html!()

%Article{}
|> Article.changeset(%{
  title: title,
  slug: "2022-09-14-test-post",
  body: markdown,
  summary: summary,
  date: "2022-09-05"
})
|> Repo.insert()

%Article{}
|> Article.changeset(%{
  title: "Introducing Animaginary: High performance web animations",
  slug: "introducing-animaginary-high-performance-web-animations",
  body:
    "When you’re building a website for a company as ambitious as Planetaria, you need to make an impression. I wanted people to visit our website and see animations that looked more realistic than reality itself.",
  summary:
    "When you’re building a website for a company as ambitious as Planetaria, you need to make an impression. I wanted people to visit our website and see animations that looked more realistic than reality itself.",
  date: "2022-09-02"
})
|> Repo.insert()

%Article{}
|> Article.changeset(%{
  title: "Rewriting the cosmOS kernel in Rust",
  slug: "rewriting-the-cosmos-kernel-in-rust",
  body:
    "When we released the first version of cosmOS last year, it was written in Go. Go is a wonderful programming language, but it’s been a while since I’ve seen an article on the front page of Hacker News about rewriting some important tool in Go and I see articles on there about rewriting things in Rust every single week.",
  summary:
    "When you’re building a website for a company as ambitious as Planetaria, you need to make an impression. I wanted people to visit our website and see animations that looked more realistic than reality itself.",
  date: "2022-07-14"
})
|> Repo.insert()
