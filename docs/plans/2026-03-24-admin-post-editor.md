# Admin Post Editor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an authenticated admin inside the Phoenix app so posts can be created and edited on-site with rich text content and R2-backed image uploads.

**Architecture:** Add a small `/admin` area protected by Basic Auth, implemented with conventional Phoenix controllers and HEEx templates. Store post bodies as trusted rich HTML in `html_body`, derive plain text for metadata/read time, upload embedded images to Cloudflare R2 through a storage adapter, and preserve compatibility with the existing GitHub sync by marking article source.

**Tech Stack:** Phoenix 1.7, Ecto, HEEx, Trix, Plug.BasicAuth, ExAws S3-compatible uploads to Cloudflare R2

---

### Task 1: Add focused tests for the new admin-backed post flow

**Files:**
- Create: `test/blog/posts_admin_test.exs`
- Create: `test/blog_web/controllers/admin_article_controller_test.exs`
- Create: `test/blog_web/controllers/admin_upload_controller_test.exs`
- Modify: `test/support/conn_case.ex`

**Step 1: Write the failing tests**

- Assert `Blog.Posts.create_article/1` can create an admin-authored article with HTML content, generated metadata, and a `source` of `admin`.
- Assert `Blog.Posts.update_article/2` can update an article and preserve a stable hash ID.
- Assert `/admin/articles` requires auth.
- Assert authenticated create/edit pages render.
- Assert the image upload endpoint accepts an image, delegates to storage, and returns a JSON URL.

**Step 2: Run the targeted tests to verify they fail**

Run:

```bash
mix test test/blog/posts_admin_test.exs test/blog_web/controllers/admin_article_controller_test.exs test/blog_web/controllers/admin_upload_controller_test.exs
```

Expected: failures because the admin APIs, routes, and storage modules do not exist yet.

### Task 2: Add article write APIs and source tracking

**Files:**
- Create: `priv/repo/migrations/*_add_source_to_articles.exs`
- Modify: `lib/blog/posts.ex`
- Modify: `lib/blog/posts/article.ex`
- Modify: `lib/blog/posts/category.ex`
- Modify: `lib/blog_web/live/article_live/show.ex`

**Step 1: Write the minimal schema/context implementation**

- Add an article `source` field with values like `github` and `admin`.
- Implement:
  - `list_articles/0`
  - `list_articles_for_admin/0`
  - `create_article/1`
  - `update_article/2`
  - `change_article/2`
  - `get_article!/1`
- Ensure a `posts` category exists for admin-created content.
- Generate slug, summary fallback, plain-text body, public path, and admin source automatically.
- Update read-time calculation to derive text from HTML instead of assuming markdown/plain text.

**Step 2: Run the targeted data tests**

Run:

```bash
mix test test/blog/posts_admin_test.exs
```

Expected: pass after the context is implemented.

### Task 3: Add R2 storage adapter and upload endpoint

**Files:**
- Modify: `mix.exs`
- Modify: `config/config.exs`
- Modify: `config/dev.exs`
- Modify: `config/test.exs`
- Modify: `config/runtime.exs`
- Create: `lib/blog/storage.ex`
- Create: `lib/blog/storage/adapter.ex`
- Create: `lib/blog/storage/r2.ex`
- Create: `lib/blog/storage/test.ex`
- Create: `lib/blog_web/controllers/admin_upload_controller.ex`

**Step 1: Write the minimal storage layer**

- Add `ex_aws` / `ex_aws_s3` deps.
- Configure S3-compatible endpoint settings for R2.
- Implement a wrapper module that delegates to a configured adapter.
- Implement an R2 adapter that uploads bytes to a generated key and returns a public URL.
- Implement a test adapter that records a deterministic fake URL.

**Step 2: Add the upload controller**

- Accept multipart image uploads from the editor.
- Reject non-image content types.
- Return JSON with the uploaded asset URL.

**Step 3: Run the targeted upload tests**

Run:

```bash
mix test test/blog_web/controllers/admin_upload_controller_test.exs
```

Expected: pass with the test storage adapter.

### Task 4: Build the authenticated admin UI

**Files:**
- Create: `lib/blog_web/plugs/admin_auth.ex`
- Create: `lib/blog_web/controllers/admin_article_controller.ex`
- Create: `lib/blog_web/templates/admin_article/index.html.heex`
- Create: `lib/blog_web/templates/admin_article/new.html.heex`
- Create: `lib/blog_web/templates/admin_article/edit.html.heex`
- Create: `lib/blog_web/templates/admin_article/form.html.heex`
- Modify: `lib/blog_web/router.ex`
- Modify: `lib/blog_web/templates/layout/root.html.heex`

**Step 1: Protect the admin scope**

- Add an `/admin` browser scope using a dedicated auth plug.
- Keep credentials in runtime config / env vars.

**Step 2: Implement the pages**

- Index page listing articles, source, updated date, and edit links.
- New/edit form with title, summary, author, date, slug, and rich body editor.
- Standard create/update actions with flash messages and redirects.

**Step 3: Run the controller tests**

Run:

```bash
mix test test/blog_web/controllers/admin_article_controller_test.exs
```

Expected: pass with auth and CRUD pages wired up.

### Task 5: Add Trix rich text editor and image attachment uploads

**Files:**
- Modify: `assets/package-lock.json`
- Create: `assets/package.json`
- Modify: `assets/js/app.js`
- Modify: `assets/css/app.css`
- Modify: `lib/blog_web/templates/admin_article/form.html.heex`

**Step 1: Install and wire Trix**

- Add Trix as an asset dependency.
- Import its JS/CSS.
- Render a hidden input plus `<trix-editor>`.

**Step 2: Attach uploads**

- Listen for `trix-attachment-add`.
- POST attached files to the admin upload endpoint with CSRF.
- On success, assign the returned URL back onto the Trix attachment.

**Step 3: Verify manually**

Run:

```bash
mix test test/blog/posts_admin_test.exs test/blog_web/controllers/admin_article_controller_test.exs test/blog_web/controllers/admin_upload_controller_test.exs
mix format
```

Then manually start the server and confirm:

```bash
mix phx.server
```

- Open `/admin/articles`
- Authenticate
- Create a post
- Insert an image
- Confirm the public post page renders correctly

### Task 6: Keep GitHub sync compatible instead of breaking current content

**Files:**
- Modify: `lib/blog/writer/post_writer.ex`

**Step 1: Prevent GitHub sync from overwriting admin-owned posts**

- When syncing GitHub articles, skip updates for existing articles whose source is `admin`.
- Continue importing or refreshing legacy `github` posts.

**Step 2: Run focused verification**

Run:

```bash
mix test test/blog/posts_admin_test.exs
```

Expected: admin-authored posts remain distinct from synced posts.
