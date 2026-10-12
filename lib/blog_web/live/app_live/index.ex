defmodule BlogWeb.AppLive.Index do
  use BlogWeb, :live_view

  @apps [
    %{
      slug: "for-when",
      name: "For When",
      category: "READING & CURIOSITY",
      headline: "Good reads. On your time.",
      summary:
        "Save the articles that catch your eye. Read them in a quiet space, and keep the ideas you want to return to.",
      url: "https://forwhen.thiagoramos.me",
      domain: "forwhen.thiagoramos.me",
      image: "/images/apps/for-when-reader.png",
      image_alt: "For When with a saved reading list, tags, and an open article in the reader",
      second_image: "/images/apps/for-when-notes.png",
      second_alt: "For When notes view with a saved quote and a personal note",
      detail_heading: "From an open tab to an idea worth keeping.",
      detail:
        "Some articles deserve more than a quick glance. For When gives them a place to wait, a clean reader when you are ready, and notes to help you remember what mattered.",
      features: [
        {"Save it for later",
         "Add an article by its URL and keep your reading list in one place."},
        {"Read at your own pace", "Enjoy a clean reader that remembers where you left off."},
        {"Keep the useful parts",
         "Highlight passages, write notes, and organize articles with tags."}
      ],
      second_heading: "Keep the thought, not just the link.",
      second_copy:
        "Bring your highlights and notes together. Return to a useful passage without searching through every article.",
      pages: [
        {"home", "Home", "Keep your next reads close.",
         "Save articles in one library with titles, reading times, progress, and tags. Search your saved reads or add a new link when something catches your attention."},
        {"reader", "Reader", "Give an article your attention.",
         "Open a saved article in a clean reading view alongside your library. Adjust the text, follow your reading progress, and return to the place you left off."},
        {"news", "News", "Find your next good read.",
         "Browse recent stories from the sites you follow. Open a story to read it, or save it to your library so you can return when you have time."},
        {"sources", "News Sources", "Choose what reaches your feed.",
         "Pick the publications you want to follow across news, ideas, technology, and science. Update your choices as your interests change."},
        {"read", "Read", "Return to something you finished.",
         "Keep completed articles in their own view. Reopen a useful piece, revisit its ideas, or mark it unread when you want to read it again."},
        {"favorites", "Favorites", "Keep the articles worth revisiting.",
         "Mark an article as a favorite to find it quickly later. Build a small collection of reads you want to share, reread, or keep close."},
        {"archive", "Archive", "Clear your list without losing a read.",
         "Move articles out of your active reading list when you are done with them. Browse the archive and return an article to your library whenever you need it."},
        {"tags", "Tags", "Follow an interest through your library.",
         "Group articles with tags such as reading, design, or Elixir. Select a tag in the sidebar to see related articles, and give a read more than one tag when it fits."},
        {"notes", "Notes", "Keep the idea, in your own words.",
         "Find articles with saved notes, then open their quotes and comments together. Return to a passage that mattered without reading the whole article again."}
      ]
    },
    %{
      slug: "todo",
      name: "Progress Flow",
      category: "PLANNING & FOCUS",
      headline: "A clearer plan for your day.",
      summary:
        "Turn a list of things to do into a plan. Organize your tasks, track your time, and see how your work adds up.",
      url: "https://app.thiagoramos.me",
      domain: "app.thiagoramos.me",
      image: "/images/apps/todo-home.png",
      image_alt:
        "Progress Flow Home page with a backlog, daily task columns, channels, and timers",
      second_image: "/images/apps/todo-planning.png",
      second_alt:
        "Progress Flow Daily Planning board with tasks grouped by status and a time budget",
      detail_heading: "Plan the work. Make time for it.",
      detail:
        "A task list tells you what needs doing. Progress Flow helps you decide when to do it, keep track of the time it takes, and pick up unfinished work the next day.",
      features: [
        {"Give each day a plan",
         "Arrange tasks by day, split work into subtasks, and keep future ideas in your backlog."},
        {"Know where your time goes",
         "Set time estimates and use task timers to compare your plan with the work you did."},
        {"Keep work in order",
         "Group tasks by channel, set recurring tasks, and review your progress in reports."}
      ],
      second_heading: "Your day, with room to adjust.",
      second_copy:
        "See your tasks in a timeline, move between days, and keep your work and personal plans in view.",
      pages: [
        {"home", "Home", "See what comes next.",
         "Capture ideas in your backlog, then plan them across the coming days. Keep channels, task timers, and completed work in view as you adjust your schedule."},
        {"planning", "Daily Planning", "Give today a clear plan.",
         "Move tasks through To Do, In Progress, and Completed. Compare the time you estimated with the time you have used, and see how much room remains in your day."},
        {"projects", "Projects", "Keep related work together.",
         "Give each project a name, a description, and a place for its tasks. Open a project from the sidebar to return to the work without searching across days."},
        {"project", "Project Workspace", "Write a plan you can act on.",
         "Build a project from sections, tasks, and notes in one document. Add dates, channels, and time estimates as you write, then use filters to focus on what needs attention."},
        {"reports", "Weekly/Monthly Review", "Learn from the time you spend.",
         "Review completed tasks, total time, and your daily activity. Compare estimated and actual time, filter by channel, and switch between weekly and monthly views."},
        {"summary", "Weekly Summary", "Keep a record of your work.",
         "Choose a date range and channels, then review tasks with their status, dates, notes, and time spent. Download the summary as Markdown to keep or share."},
        {"integrations", "Integrations", "Bring your work into one place.",
         "Connect Google Calendar to create tasks from selected calendars. Connect Linear to import an issue’s title and content when you paste its URL into a new task. Each service needs a connected account."},
        {"ai", "Planning Copilot", "Ask for help with your plan.",
         "Open the AI workspace with today’s tasks in view. Start a chat for task help, and use the task controls to open, start, pause, or complete work from the same screen."},
        {"settings", "Account Settings", "Make the workspace your own.",
         "Create channels, choose their colors, and set your theme. Manage your email and password, or create personal API tokens to connect an MCP client."}
      ]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, apps: @apps, apps_active: true, about_active: false),
     layout: {BlogWeb.LayoutView, :marketing}}
  end

  @impl true
  def handle_params(params, url, socket) do
    app = Enum.find(@apps, &(&1.slug == params["slug"]))

    if socket.assigns.live_action == :show && is_nil(app) do
      raise BlogWeb.AppLive.NotFoundError
    end

    {:noreply,
     assign(socket,
       app: app,
       page_path: URI.parse(url).path,
       page_image: if(app, do: app.image, else: "/images/apps/for-when-reader.png"),
       page_title: if(app, do: app.name, else: "Apps"),
       page_description:
         if(app,
           do: app.summary,
           else: "Apps by Thiago Ramos for reading, planning, and making better use of your time."
         )
     )}
  end
end
