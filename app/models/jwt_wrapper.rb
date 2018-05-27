class CurrentSession
  attr_accessor :uid, :user_id, :expired_at

  def initialize(uid, user_id, expired_at)
    @uid = uid
    @user_id = user_id
    @expired_at = expired_at
  end
end

class JwtWrapper
  def self.encode(uid, user_id)
    exp = Time.now.to_i + CONSTANTS::JWT_EXPIRATIONTIME
    payload = { uid: uid, user_id: user_id, iss: CONSTANTS::JWT_ISS, exp: exp }
    jwt = JWT.encode(payload, CONSTANTS::JWT_SECRET_KEY, CONSTANTS::JWT_ALGORITHMS_TYPE)
    { jwt: jwt, expired_at: Time.zone.at(exp) }
  end

  def self.decode(token, verify_expiration = true)
    option = {
      algorithm: CONSTANTS::JWT_ALGORITHMS_TYPE,
      iss: CONSTANTS::JWT_ISS,
      verify_iss: true,
      verify_expiration: verify_expiration
    }
    decoded_tokens = JWT.decode(token, CONSTANTS::JWT_SECRET_KEY, true, option)
    decoded_token = decoded_tokens[0]
    uid = decoded_token['uid']
    user_id = decoded_token['user_id']
    expired_at = Time.zone.at(decoded_token['exp'])

    CurrentSession.new(uid, user_id, expired_at)
  end

  def self.decode_jwt(request_headers)
    authorization = request_headers[:Authorization]
    raise ArgumentError.new('No Authorization header') unless authorization

    divided = authorization.split(/\s/)
    token = divided[1]
    decode(token)
  end
end
