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

alias Blog.Posts.{Article, Category}
alias Blog.Repo

file_string =
  "priv/posts/post.html.md"
  |> File.read!()
  |> String.split("\n")

[title, summary] =
  file_string
  |> Enum.take(2)

markdown = file_string |> Enum.drop(1) |> Earmark.as_html!()

{:ok, posts_category} =
  %Category{}
  |> Category.changeset(%{name: "Posts", slug: "posts"})
  |> Repo.insert()

html_body = ~s(
<h2>
Special Announcement</h2>
<p>
Hey folks, I launch my first Elixir/Phoenix LiveView course. In this course I am teaching you how to create the Wordle Game with Elixir and Phoenix LiveView. In this course I teach you about elixir, TDD, how to organize your project, how to create and use function components, how to create and use animations with TailwindCSS and Phoenix LiveView and in the end you will have a complete functional wordle game to show to your friends.</p>
<p>
The course is with a special offer with 50% of discount. Go here and check it out:</p>
<p>
<a href="https://indiecourses.com/catalog/54c9e6b0-f39e-43a5-b775-a0de3f634b58">https://indiecourses.com/catalog/54c9e6b0-f39e-43a5-b775-a0de3f634b58</a></p>
<h2>
How to create migrations with Ecto And How to insert data with associations</h2>
<p>
This post belongs to a series of posts about Ecto. This is the first one.</p>
<p>
When you are starting your project you probably have a design concept or a sketch of the UI ready. But one of the things you also need to have is the domain model of your application and they are usually tables in a database.</p>
)

{:ok, _article} =
  %Article{}
  |> Article.changeset(%{
    title: title,
    author: "Thiago Ramos",
    slug: "2022-09-14-test-post",
    html_url: "2022-09-14-test-post",
    body: markdown,
    html_body: html_body,
    summary: summary,
    date: "2022-09-05",
    category_id: posts_category.id,
    hash_id: :crypto.hash(:sha, markdown) |> Base.encode64()
  })
  |> Repo.insert()

{:ok, _article} =
  %Article{}
  |> Article.changeset(%{
    title: title,
    author: "Thiago Ramos",
    slug: "2022-09-14-test-post-2",
    html_url: "2022-09-14-test-post-2",
    body: markdown,
    html_body: html_body,
    summary: summary,
    date: "2022-09-10",
    category_id: posts_category.id,
    hash_id: :crypto.hash(:sha, "test") |> Base.encode64()
  })
  |> Repo.insert()
