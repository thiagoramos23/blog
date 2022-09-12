defmodule BlogWeb.Components.Footer do
  use Phoenix.Component

  def footer(assigns) do
    ~H"""
      <footer class="mt-32">
        <div class="sm:px-8">
          <div class="mx-auto max-w-7xl lg:px-8">
            <div class="pt-10 pb-16 border-t border-zinc-100 dark:border-zinc-700/40">
              <div class="relative px-4 sm:px-8 lg:px-12">
                <div class="max-w-2xl mx-auto lg:max-w-5xl">
                  <div class="flex flex-col items-center justify-between gap-6 sm:flex-row">
                    <div class="flex gap-6 text-sm font-medium text-zinc-800 dark:text-zinc-200">
                      <a class="transition hover:text-teal-500 dark:hover:text-teal-400" href="/about">About</a>
                      <!--
                      <a class="transition hover:text-teal-500 dark:hover:text-teal-400" href="/projects">Projects</a>
                      <a class="transition hover:text-teal-500 dark:hover:text-teal-400" href="/speaking">Speaking</a>
                      -->
                    </div>
                    <p class="text-sm text-zinc-400 dark:text-zinc-500">© <!-- --><%= Date.utc_today().year%><!-- --> TheSlowDev. All rights reserved.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </footer>
    """
  end
end
