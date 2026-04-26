# Blog

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Kamal

This repo includes a Kamal 2 deployment setup in [config/deploy.yml](/Users/dev/dev/projects/personal/blog-phoenix/config/deploy.yml) plus a Dockerized wrapper at [bin/kamal](/Users/dev/dev/projects/personal/blog-phoenix/bin/kamal).

Before the first deploy:

  * Set `KAMAL_APP_HOST` to your production hostname, or replace the placeholder in `config/deploy.yml`.
  * Review the server IP and Docker Hub username defaults in `config/deploy.yml`.
  * Review the local `.kamal/secrets` file, which is seeded from [.kamal/secrets.example](/Users/dev/dev/projects/personal/blog-phoenix/.kamal/secrets.example).

Useful commands:

  * `bin/kamal setup`
  * `bin/kamal deploy`
  * `bin/kamal migrate`
  * `bin/kamal console`
