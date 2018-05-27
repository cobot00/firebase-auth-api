class User < ApplicationRecord
  scope :active, -> { where(deleted: false) }

  def self.find_active(uid)
    active.find_by(uid: uid)
  end

  def self.sign_up!(email, password, name)
    result = Firebase::AuthClient.sign_up!(email, password)
    params = { uid: result.uid, name: name, email: email }
    User.create!(params)
  end
end
