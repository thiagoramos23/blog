# AGENTS.md

## Project Overview

- This repo is a Phoenix 1.7 / LiveView 1.0 blog application.
- The main domain is `Blog.Posts`, backed by the `articles` and `categories` tables.
- Public pages are rendered with LiveView under `lib/blog_web/live/`.
- Posts are currently imported from GitHub by `Blog.Writer.PostWriter` and supervised by `Blog.Writer.PostWriterSupervisor`.
- View analytics are recorded through a browser plug in `BlogWeb.Router` and persisted via `Blog.Metric.StatsServer` / `Blog.Metrics`.

## Repo Map

- `lib/blog/`
  - Application, contexts, schemas, background workers, and metrics code.
- `lib/blog_web/`
  - Router, endpoint, LiveViews, templates, and function components.
- `assets/`
  - Frontend entrypoints: `assets/js/app.js` and `assets/css/app.css`.
- `priv/repo/migrations/`
  - Database schema history.
- `priv/repo/seeds.exs`
  - Seed data for local setup.
- `config/deploy.yml`
  - Kamal deployment configuration for the Hetzner host.

## Current Content Flow

- Articles are stored in Postgres, not read directly at request time from GitHub.
- `Blog.Writer.PostWriter` fetches a GitHub directory listing, downloads markdown files, parses a simple metadata header, converts markdown to HTML with `Earmark`, and upserts rows by `slug`.
- The worker is scheduled every 4 hours.
- `handle_continue/2` currently does **not** fetch immediately on boot because `get_posts_and_upsert()` is commented out.
- If content authoring changes, inspect `lib/blog/writer/post_writer.ex`, `lib/blog/application.ex`, and the `articles` schema together.

## Local Development

- Tool versions are tracked in `.tool-versions`:
  - Erlang `27.2`
  - Elixir `1.18.2-otp-27`
- Start from the usual Phoenix flow:
  - `mix deps.get`
  - `mix ecto.setup`
  - `mix phx.server`
- Useful commands:
  - `mix test`
  - `mix format`
  - `mix ecto.reset`
  - `mix assets.deploy`
- Development and test expect a local Postgres instance with the defaults in `config/dev.exs` and `config/test.exs`.

## Environment Variables

- Production requires:
  - `DATABASE_URL`
  - `SECRET_KEY_BASE`
  - `PHX_SERVER=true`
- Optional production tuning:
  - `PORT`
  - `PHX_HOST`
  - `POOL_SIZE`
  - `ECTO_IPV6`
- GitHub post syncing depends on:
  - `GITHUB_TOKEN`

## Coding Conventions

- Follow existing Phoenix conventions:
  - business logic in `lib/blog/` contexts and modules
  - routing in `lib/blog_web/router.ex`
  - page behavior in LiveViews
  - reusable UI in `lib/blog_web/live/components/`
- Prefer small, direct modules over abstraction-heavy patterns.
- Keep changes formatted with `mix format`.
- When adding data features, update schema, context, migration, and the consuming LiveView together.
- When adding browser-side behavior, prefer LiveView first and only add custom JS/hooks when necessary.

## Known Caveats

- The generated CRUD-style tests and fixtures under:
  - `test/blog/posts_test.exs`
  - `test/support/fixtures/posts_fixtures.ex`
  - `test/blog_web/live/article_live_test.exs`
  reference `create_article/1`, `update_article/2`, and related flows that do not currently exist in `Blog.Posts`.
- Do not assume the current test suite is a green baseline until those tests are reconciled with the real codebase.
- There is an untracked `.DS_Store` in the repo root. Avoid including it in commits.

## High-Value Files

- `mix.exs`
  - dependencies, aliases, and app definition
- `lib/blog/posts.ex`
  - read-side posts context
- `lib/blog/posts/article.ex`
  - article schema and changeset
- `lib/blog/writer/post_writer.ex`
  - GitHub ingestion and upsert logic
- `lib/blog_web/router.ex`
  - public routes and request metric plug
- `lib/blog_web/live/article_live/index.ex`
  - article listing page
- `lib/blog_web/live/article_live/show.ex`
  - article detail page

## Change Guidance

- Before removing or replacing the GitHub sync path, decide whether imported posts should coexist with manually-authored posts or whether GitHub becomes legacy-only.
- If you introduce admin functionality, authentication and authorization will need to be added explicitly; there is no auth system in the current app.
- If you introduce file uploads, check both the database schema impact and deployment/runtime configuration together.
