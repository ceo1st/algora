defmodule Algora.Repo.Migrations.AddTalentsPipelineLocationIndex do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create_if_not_exists index(
             :users,
             [:country, :location_iso_lvl4],
             name: "idx_users_pipeline_location",
             where: """
             (type)::text = 'individual' \
             AND provider_login IS NOT NULL \
             AND opt_out_algora = false \
             AND open_to_new_role = true \
             AND (open_to_ic OR NOT open_to_manager) \
             AND (open_to_fulltime OR NOT open_to_contract)\
             """,
             concurrently: true
           )
  end
end
