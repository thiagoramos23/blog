defmodule Highlighter do
  @moduledoc """
  This code was stolen from NimblePublisher and can be found here:
  https://github.com/dashbitco/nimble_publisher/blob/abee26e755c6dc638341869f090bc1d63c690f3f/lib/nimble_publisher/highlighter.ex#L1
  """

  @doc """
  Highlights all code block in an already generated HTML document.
  """
  def highlight(html) do
    Regex.replace(
      ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/,
      html,
      &highlight_code_block(&1, &2, &3)
    )
  end

  defp highlight_code_block(full_block, lang, code) do
    case pick_language_and_lexer(lang) do
      {_language, nil, _opts} -> full_block
      {language, lexer, opts} -> render_code(language, lexer, opts, code)
    end
  end

  defp pick_language_and_lexer(""), do: {"text", nil, []}

  defp pick_language_and_lexer(lang) do
    IO.inspect(lang)
    IO.inspect(Makeup.Registry.fetch_lexer_by_name(lang))

    case Makeup.Registry.fetch_lexer_by_name(lang) do
      {:ok, {lexer, opts}} -> {lang, lexer, opts}
      :error -> {lang, nil, []}
    end
  end

  defp render_code(lang, lexer, lexer_opts, code) do
    highlighted =
      code
      |> unescape_html()
      |> IO.iodata_to_binary()
      |> Makeup.highlight_inner_html(
        lexer: lexer,
        lexer_options: lexer_opts,
        formatter_options: [highlight_tag: "span"]
      )

    ~s(<pre class="bg-gray-100 dark:bg-slate-300"><code class="makeup #{lang} highlight">#{highlighted}</code></pre>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
