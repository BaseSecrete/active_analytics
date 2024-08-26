class CreateActiveAnalyticsBrowsersPerDays < ActiveRecord::Migration[7.1]
  def change
    create_table :active_analytics_browsers_per_days do |t|
      t.string :site, null: false
      t.string :name, null: false
      t.string :version, null: false
      t.date :date, null: false
      t.bigint :total, null: false, default: 1
      t.timestamps
    end
    add_index :active_analytics_browsers_per_days, :date
    add_index :active_analytics_browsers_per_days, [:site, :name, :date], name: "idx_active_analytics_browsers_per_days_on_site_name_and_date"
    add_index :active_analytics_browsers_per_days, [:site, :name, :version], name: "idx_active_analytics_browsers_per_days_on_site_name_and_version"
  end
end
