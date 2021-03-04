class CreateActiveAnalyticsViewsPerDays < ActiveRecord::Migration[5.2]
  def up
    create_table :active_analytics_views_per_days do |t|
      t.string :site, null: false
      t.string :page, null: false
      t.date :date, null: false
      t.bigint :total, null: false, default: 1
      t.string :referer_host
      t.string :referer_path
      t.timestamps
    end
    add_index :active_analytics_views_per_days, :date
    add_index :active_analytics_views_per_days, [:site, :page, :date]
    add_index :active_analytics_views_per_days, [:referer_host, :referer_path, :date], name: "index_active_analytics_views_per_days_on_referer_and_date"
  end

  def down
    drop_table :active_analytics_views_per_days
  end
end
