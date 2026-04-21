defmodule BlogWeb.Admin.AdminLoginLiveTest do
  use BlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Blog.BackofficeFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/admin/admins/log_in")

      assert html =~ "Log in"
      assert html =~ "Register"
      assert html =~ "Forgot your password?"
      assert has_element?(lv, "#auth-shell")
      refute has_element?(lv, "nav a", "About")
      refute has_element?(lv, "nav a", "Articles")
      refute has_element?(lv, "footer")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admin/admins/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "admin login" do
    test "redirects if admin login with valid credentials", %{conn: conn} do
      password = "123456789abcd"
      admin = admin_fixture(%{password: password})

      {:ok, lv, _html} = live(conn, ~p"/admin/admins/log_in")

      form =
        form(lv, "#login_form",
          admin: %{email: admin.email, password: password, remember_me: true}
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/admin/admins/log_in")

      form =
        form(lv, "#login_form",
          admin: %{email: "test@email.com", password: "123456", remember_me: true}
        )

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"

      assert redirected_to(conn) == "/admin/admins/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/admins/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|a[href="#{~p"/admin/admins/register"}"]|)
        |> render_click()
        |> follow_redirect(conn, ~p"/admin/admins/register")

      assert login_html =~ "Register"
    end

    test "redirects to forgot password page when the Forgot Password button is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/admin/admins/log_in")

      {:ok, conn} =
        lv
        |> element(~s|a[href="#{~p"/admin/admins/reset_password"}"]|)
        |> render_click()
        |> follow_redirect(conn, ~p"/admin/admins/reset_password")

      assert conn.resp_body =~ "Forgot your password?"
    end
  end
end
