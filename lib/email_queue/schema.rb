ActiveRecord::Schema.define do

  if not table_exists?(:email_queue)
    create_table :email_queue do |t|
      t.string :from_email_address
      t.string :to_email_address
      t.string :subject
      t.text :body

      t.string :worker_id
      t.integer :status, default:  0
      t.text :error_details

      t.timestamps null: false
    end

  end

  if not table_exists?(:email_queue_archive)
    execute('create table email_queue_archive like email_queue')
  end

  if not index_exists?(:email_queue, [:status, :worker_id])
    add_index(:email_queue, [:status, :worker_id])
  end

end