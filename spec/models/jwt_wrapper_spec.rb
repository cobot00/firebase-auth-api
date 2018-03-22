require 'rails_helper'

describe JwtWrapper do
  let(:token) { 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJkdW1teSIsImFjY291bnRfaWQiOjEsImlzcyI6ImZpcmJhc2UtYXV0aC1hcGkiLCJleHAiOjE1MjE3Mzk5MDl9.3xHicg0ygfFGT-H12XwywA8AblK2ggHAKE3qIAMcHRc' }
  let(:headers) { { Authorization: 'Bearer ' + token } }

  describe '.decode' do
    context 'トークンの有効期限が過ぎている' do
      before do
        Timecop.freeze(Time.zone.local(2018, 3, 23, 9, 0, 0))
      end

      after do
        Timecop.return
      end

      it '有効期限切れで例外が発生する' do
        expect { JwtWrapper.decode(token) }
              .to raise_error(JWT::ExpiredSignature, 'Signature has expired')
      end

      it 'セッション情報が返される' do
        result = JwtWrapper.decode(token, false)
        expect(result.account_id).to eq 1
        expect(result.uid).to eq 'dummy'
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

    it 'JWTのaccount_idを返す' do
      expect(JwtWrapper.decode_jwt(headers).account_id).to eq 1
    end
  end
end
