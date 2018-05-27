require 'rails_helper'

# 外部APIに接続するので仕方なくif文で実行可否を判定しています
RSpec.describe Firebase::AuthClient, type: :model do
  let(:email) { ENV['FIREBASE_EMAIL'] }
  let(:password) { ENV['FIREBASE_PASSWORD'] }

  describe '.authenticate!' do
    context 'ユーザーが登録されている' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'] }
        end
      end

      it 'Firebaseに認証され、トークンが返される' do
        if email.present? && password.present?
          result = Firebase::AuthClient.authenticate!(email, password)
          expect(result.size).to eq 3
          expect(result[:session_token]).not_to be_nil
          expect(result[:refresh_token]).not_to be_nil
          expect(result[:expired_at]).not_to be_nil
        end
      end
    end

    context 'ユーザーが登録されていない' do
      it '例外が発生する' do
        if email.present? && password.present?
          expect { Firebase::AuthClient.authenticate!(email, password) }
            .to raise_error(Firebase::AuthenticationException, 'ユーザー登録されていないので利用できません')
        end
      end
    end

    context '削除されたユーザー' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'], deleted: true }
        end
      end

      it '例外が発生する' do
        if email.present? && password.present?
          expect { Firebase::AuthClient.authenticate!(email, password) }
            .to raise_error(Firebase::AuthenticationException, 'ユーザー登録されていないので利用できません')
        end
      end
    end
  end

  describe '.sign_in_email!' do
    it 'Firebaseに認証され、トークンが返される' do
      if email.present? && password.present?
        response = Firebase::AuthClient.sign_in_email!(email, password)
        expect(response.id_token).not_to be_nil
        expect(response.refresh_token).not_to be_nil
        expect(response.uid).not_to be_nil
      end
    end

    context 'メールアドレスが間違っている' do
      let(:email) { 'wrong_email_adress' }

      it '例外が発生する' do
        if email.present? && password.present?
          expect { Firebase::AuthClient.sign_in_email!(email, password) }
            .to raise_error(Firebase::AuthenticationException, 'メールアドレスまたはパスワードに誤りがあります')
        end
      end
    end

    context 'パスワードが間違っている' do
      let(:password) { 'wrong_password' }

      it '例外が発生する' do
        if email.present? && password.present?
          expect { Firebase::AuthClient.sign_in_email!(email, password) }
            .to raise_error(Firebase::AuthenticationException, 'メールアドレスまたはパスワードに誤りがあります')
        end
      end
    end
  end

  describe '.refresh!' do
    context 'ユーザーが登録されている' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'] }
        end
      end

      it 'Firebaseに認証され、トークンがリフレッシュされる' do
        if email.present? && password.present?
          response = Firebase::AuthClient.authenticate!(email, password)
          authorization_header = "Bearer #{response[:refresh_token]}, Session #{response[:session_token]}"
          sleep(2) # 有効期間を変更させてトークンを置き換えさせるためにシステム時刻を進める
          result = Firebase::AuthClient.refresh!(authorization_header)

          expect(result.size).to eq 3
          expect(result[:session_token]).not_to eq response[:session_token]
          expect(result[:refresh_token]).not_to be_nil
          expect(result[:expired_at]).not_to be_nil
        end
      end
    end

    context 'ユーザーが削除されている' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'] }
        end
      end

      it '例外が発生する' do
        if email.present? && password.present?
          response = Firebase::AuthClient.authenticate!(email, password)
          authorization_header = "Bearer #{response[:refresh_token]}, JWT #{response[:session_token]}"

          user = User.find_by(uid: ENV['FIREBASE_UID'])
          user.update(deleted: true)

          expect { Firebase::AuthClient.refresh!(authorization_header) }
            .to raise_error(Firebase::AuthenticationException)
        end
      end
    end
  end
end
