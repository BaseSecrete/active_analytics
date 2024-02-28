class AddUserAgentToViewsPerDays < ActiveRecord::Migration[6.0]
  def change
    add_column :active_analytics_views_per_days, :device_type, :string
    add_column :active_analytics_views_per_days, :operating_system, :string
    add_column :active_analytics_views_per_days, :browser, :string

    remove_column :active_analytics_views_per_days, :created_at, :datetime
    remove_column :active_analytics_views_per_days, :updated_at, :datetime

    add_index :active_analytics_views_per_days,
              [:date, :site, :page, :referrer_path, :referrer_host, :browser, :device_type, :operating_system],
              name: "index_active_analytics_views_per_days_on_user_agent_and_date",
              unique: true
  end
end
