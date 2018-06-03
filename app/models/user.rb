class User < ApplicationRecord
  PERMITTED_FIELDS = %i[name email password].freeze

  scope :active, -> { where(deleted: false) }

  def self.find_active(uid)
    active.find_by(uid: uid)
  end

  def self.find_with_id(id)
    active.find_by!(id: id)
  end

  def self.sign_up!(email, password, name)
    result = Firebase::AuthClient.sign_up!(email, password)
    params = { uid: result.uid, name: name, email: email }
    User.create!(params)
  end

  def self.disable!(id)
    record = active.find_by!(id: id)
    record.update!(deleted: true)
  end
end
