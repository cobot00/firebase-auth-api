module Firebase
  ERROR_MESSAGES = {
    'EMAIL_NOT_FOUND' => 'メールアドレスまたはパスワードに誤りがあります',
    'INVALID_EMAIL' => 'メールアドレスまたはパスワードに誤りがあります',
    'INVALID_PASSWORD' => 'メールアドレスまたはパスワードに誤りがあります',
    'NO_USER' => 'ユーザー登録されていないので利用できません',
    'INVALID_REFRESH_TOKEN' => '再認証に失敗しました',
    'EMAIL_EXISTS' => '登録済のメールアドレスです'
  }.freeze

  class AuthResponse
    attr_accessor :uid, :id_token, :refresh_token

    def initialize(raw_response)
      @uid = raw_response.body['localId'] || raw_response.body['user_id']
      @id_token = raw_response.body['idToken'] || raw_response.body['id_token']
      @refresh_token = raw_response.body['refreshToken'] || raw_response.body['refresh_token']
    end
  end

  class AuthenticationException < StandardError; end

  class AuthClient
    def self.client
      Firebase::Auth::Client.new(FIREBASE::API_KEY)
    end

    def self.sign_up!(email, password)
      response = client.sign_up_email(email, password)
      unless response.success?
        message = ERROR_MESSAGES[response.body['error']['message']] || 'ユーザー登録に失敗しました'
        raise Firebase::AuthenticationException.new(message)
      end

      Firebase::AuthResponse.new(response)
    end

    def self.sign_in_email!(email, password)
      response = client.sign_in_email(email, password)
      unless response.success?
        message = ERROR_MESSAGES[response.body['error']['message']] || 'ログインに失敗しました'
        raise Firebase::AuthenticationException.new(message)
      end

      Firebase::AuthResponse.new(response)
    end

    def self.authenticate!(email, password)
      response = sign_in_email!(email, password)
      user = User.find_active(response.uid)
      raise Firebase::AuthenticationException.new(ERROR_MESSAGES['NO_USER']) unless user

      encode(response.uid, user.id, response.refresh_token)
    end

    def self.refresh!(authorization_header)
      raise ArgumentError.new('No Authorization header') unless authorization_header
      token = authorization_header.split(/\s/)[1]

      response = refresh_token!(token)
      user = User.find_active(response.uid)
      raise Firebase::AuthenticationException.new unless user

      encode(response.uid, user.id, response.refresh_token)
    end

    def self.refresh_token!(refresh_token)
      response = client.refresh_token(refresh_token)
      raise Firebase::AuthenticationException.new unless response.success?

      Firebase::AuthResponse.new(response)
    end

    def self.send_password_reset_email!(email)
      response = client.send_confirm_code(email)
      unless response.success?
        raise Firebase::AuthenticationException.new('登録されていないメールアドレスです')
      end
    end

    class << self
      private

      def encode(uid, user_id, refresh_token)
        result = JwtWrapper.encode(uid, user_id)
        { session_token: result[:jwt],
          refresh_token: refresh_token,
          expired_at: result[:expired_at] }
      end

      def validate_session_token!(session_token)
        JwtWrapper.decode(session_token)
      end
    end
  end
end
