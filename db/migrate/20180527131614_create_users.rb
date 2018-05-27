class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, limit: 64, null: false, comment: '認証サービスが提供するユーザーID'
      t.string :name, limit: 50, null: false, comment: 'ユーザー名'
      t.string :email, limit: 250, null: false, comment: '認証サービスに登録しているメールアドレス'
      t.boolean :deleted, null: false, default: false, comment: 'true：削除済'

      t.column  :created_at, RDBMS::TIMESTAMP_WITH_TIMEZOE, default: -> { 'NOW()' }
      t.column  :updated_at, RDBMS::TIMESTAMP_WITH_TIMEZOE, default: -> { 'NOW()' }
    end

    add_index :users, :uid, name: 'idx_users_01', unique: true
  end
end
