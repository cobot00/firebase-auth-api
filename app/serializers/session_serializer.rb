class SessionSerializer < ActiveModel::Serializer
  def initialize(value)
    @value = value
  end

  def serialize
    {
      'session_token': @value[:session_token],
      'refresh_token': @value[:refresh_token],
      'expired_at': @value[:expired_at].to_i
    }
  end
end
