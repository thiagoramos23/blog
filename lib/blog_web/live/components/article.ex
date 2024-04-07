defmodule BlogWeb.Components.Article do
  use Phoenix.Component

  def article(assigns) do
    ~H"""
    <article class="md:grid md:grid-cols-4 md:items-baseline">
      <div class="relative flex flex-col items-start md:col-span-3 group">
        <h2 class="text-base font-semibold tracking-tight text-zinc-800 dark:text-zinc-100">
          <div class="absolute z-0 transition scale-95 opacity-0 -inset-y-6 -inset-x-4 bg-zinc-50 group-hover:scale-100 group-hover:opacity-100 dark:bg-zinc-800/50 sm:-inset-x-6 sm:rounded-2xl"></div>
          <.link href={@route} class="relative z-10">
            <span class="absolute z-20 -inset-y-6 -inset-x-4 sm:-inset-x-6 sm:rounded-2xl"></span>
            <%= @title %>
          </.link>
        </h2>
        <time class="md:hidden relative z-10 order-first mb-3 flex items-center text-sm text-zinc-400 dark:text-zinc-500 pl-3.5" datetime="2022-09-05">
          <span class="absolute inset-y-0 left-0 flex items-center" aria-hidden="true">
            <span class="h-4 w-0.5 rounded-full bg-zinc-200 dark:bg-zinc-500"></span>
          </span><%= @date %>
        </time>
        <p class="relative z-10 mt-2 text-sm text-zinc-600 dark:text-zinc-400"><%= String.slice(@summary, 0..300) %></p>
        <div aria-hidden="true" class="relative z-10 flex items-center mt-4 text-sm font-medium text-teal-500">
          <.link href={@route} class="relative z-10">
            Read article
          </.link>
        <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" class="w-4 h-4 ml-1 stroke-current"><path d="M6.75 5.75 9.25 8l-2.5 2.25" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"></path></svg></div>
      </div>
      <time class="relative z-10 flex items-center order-first hidden mt-1 mb-3 text-sm md:block text-zinc-400 dark:text-zinc-500" datetime="2022-09-05">
        <%= @date %>
      </time>
    </article>
    """
  end
end
