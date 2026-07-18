defmodule AlgoraWeb.Org.TeamLive do
  @moduledoc false
  use AlgoraWeb, :live_view

  alias Algora.Accounts.User
  alias Algora.Organizations

  @impl true
  def mount(%{"org_handle" => handle}, _session, socket) do
    org = Organizations.get_org_by_handle!(handle)
    members = Organizations.list_org_members(org)

    {:ok,
     socket
     |> assign(:page_title, "#{org.name} Team")
     |> assign(:org, org)
     |> assign(:members, members)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-7xl space-y-6 p-4 sm:px-6 lg:px-8">
      <.card>
        <.card_header>
          <.card_title>Team</.card_title>
          <.card_description>Members of {@org.name}</.card_description>
        </.card_header>
        <.card_content>
          <%= if Enum.empty?(@members) do %>
            <div class="flex flex-col items-center justify-center py-16 text-center">
              <.icon name="tabler-users" class="mb-4 h-16 w-16 text-muted-foreground/50" />
              <h3 class="mb-2 text-lg font-semibold text-foreground">No members yet</h3>
              <p class="text-sm text-muted-foreground">
                Team members will appear here once they join the organization
              </p>
            </div>
          <% else %>
            <div class="-mx-6 overflow-x-auto">
              <div class="inline-block min-w-full py-2 align-middle">
                <table class="min-w-full divide-y divide-border">
                  <thead>
                    <tr>
                      <th
                        scope="col"
                        class="px-6 py-3.5 text-left text-sm font-semibold"
                        style="padding-left: 4.75rem;"
                      >
                        Member
                      </th>
                      <th scope="col" class="px-6 py-3.5 text-left text-sm font-semibold">Role</th>
                      <th scope="col" class="px-6 py-3.5 text-left text-sm font-semibold">Joined</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-border">
                    <tr :for={member <- @members}>
                      <td class="whitespace-nowrap px-6 py-4">
                        <div class="flex items-center gap-3">
                          <.avatar>
                            <.avatar_image src={member.user.avatar_url} />
                            <.avatar_fallback>
                              {Algora.Util.initials(member.user.name)}
                            </.avatar_fallback>
                          </.avatar>
                          <div>
                            <div class="font-medium">{member.user.name}</div>
                            <% {role, company} =
                              case Algora.Cloud.extract_current_role_and_company(member.user) do
                                {:ok, {r, c}} -> {r, c}
                                _ -> {nil, nil}
                              end %>
                            <%= if company && String.downcase(company) == String.downcase(@org.name) do %>
                              <div class="text-sm text-muted-foreground">
                                {role}
                              </div>
                            <% else %>
                              <div class="text-sm text-muted-foreground">@{member.user.handle}</div>
                            <% end %>
                          </div>
                        </div>
                      </td>
                      <td class="whitespace-nowrap px-6 py-4">
                        <.badge>
                          {member.role |> Atom.to_string() |> String.capitalize()}
                        </.badge>
                      </td>
                      <td class="whitespace-nowrap px-6 py-4 text-sm text-muted-foreground tabular-nums">
                        {Calendar.strftime(member.inserted_at, "%b %d, %Y")}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          <% end %>
        </.card_content>
      </.card>
    </div>
    """
  end

  @impl true
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
