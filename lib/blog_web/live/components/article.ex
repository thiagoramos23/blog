defmodule BlogWeb.Components.Article do
  use Phoenix.Component

  def article(assigns) do
    ~H"""
    <article class="article-list-item">
      <time datetime={Date.to_iso8601(@date)}><%= Calendar.strftime(@date, "%B %d, %Y") %></time>
      <div>
        <h3><a href={@route}><%= @title %></a></h3>
        <p><%= String.slice(@summary, 0..300) %></p>
        <a href={@route} class="apps-text-link" aria-label={"Read #{@title}"}>Read article <span aria-hidden="true">→</span></a>
      </div>
    </article>
    """
  end
end
