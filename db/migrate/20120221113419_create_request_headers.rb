class CreateRequestHeaders < ActiveRecord::Migration
  def self.up
    create_table :request_headers do |t|
      t.integer :double_id
      t.string :name
      t.string :value
    end
  end

  def self.down
    drop_table :request_headers
  end
end
