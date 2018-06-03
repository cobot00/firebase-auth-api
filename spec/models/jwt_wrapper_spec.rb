require 'rails_helper'

describe JwtWrapper do
  let(:token) { ENV['JWT_TEST_TOKEN'] }
  let(:headers) { { Authorization: 'Bearer ' + token } }

  describe '.decode' do
    context 'トークンの有効期限が過ぎている' do
      before do
        Timecop.freeze(Time.zone.local(2018, 5, 28, 1, 0, 0))
      end

      after do
        Timecop.return
      end

      it '有効期限切れで例外が発生する' do
        if token
          expect { JwtWrapper.decode(token) }
                .to raise_error(JWT::ExpiredSignature, 'Signature has expired')
        end
      end

      it 'セッション情報が返される' do
        if token
          result = JwtWrapper.decode(token, false)
          expect(result.user_id).to eq 1
          expect(result.uid).to eq 'dummy'
        end
      end
    end
  end

  describe '.decode_jwt' do
    before do
      Timecop.freeze(Time.zone.local(2018, 3, 23, 0, 0, 0))
      stub_const('CONSTANTS::JWT_EXPIRATIONTIME', 3600)
    end

    after do
      Timecop.return
    end

    it 'JWTのuser_idを返す' do
      expect(JwtWrapper.decode_jwt(headers).user_id).to eq 1 if token
    end
  end
end
