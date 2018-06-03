require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  let(:email) { ENV['FIREBASE_EMAIL'] }
  let(:password) { ENV['FIREBASE_PASSWORD'] }
  let(:uid) { ENV['FIREBASE_UID'] }
  let(:refresh_token) { ENV['FIREBASE_REFRESH_TOKEN'] }

  describe 'POST #create' do
    context 'ユーザーが登録されている' do
      before do
        create :user, { uid: uid } if uid.present?
      end

      it '認証され、JWTが返される' do
        if email.present? && password.present?
          post :create, params: { email: email, password: password }
          expect(response).to have_http_status(:success)

          json = JSON.parse(response.body)
          expect(json.size).to eq(3)
          expect(json['session_token']).not_to be_nil
          expect(json['refresh_token']).not_to be_nil
          expect(json['expired_at']).not_to be_nil
        end
      end
    end

    context 'ユーザーが登録されていない' do
      it '400エラーが返される' do
        if email.present? && password.present?
          post :create, params: { email: email, password: password }
          expect(response).to have_http_status(:bad_request)

          json = JSON.parse(response.body, { symbolize_names: true })
          expect(json[:message]).to eq 'ユーザー登録されていないので利用できません'
        end
      end
    end

    context 'メールアドレスが間違っている' do
      let(:email) { 'wrong_email_adress' }

      it '400エラーが返される' do
        if email.present? && password.present?
          post :create, params: { email: email, password: password }
          expect(response).to have_http_status(:bad_request)

          json = JSON.parse(response.body, { symbolize_names: true })
          expect(json[:message]).to eq 'メールアドレスまたはパスワードに誤りがあります'
        end
      end
    end

    context 'パスワードが間違っている' do
      let(:password) { 'wrong_password' }

      it '400エラーが返される' do
        if email.present? && password.present?
          post :create, params: { email: email, password: password }
          expect(response).to have_http_status(:bad_request)

          json = JSON.parse(response.body, { symbolize_names: true })
          expect(json[:message]).to eq 'メールアドレスまたはパスワードに誤りがあります'
        end
      end
    end
  end

  describe 'POST #update' do
    before do
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{refresh_token}"
    end

    context 'ユーザーが登録されている' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'] }
        end
      end

      it 'リフレッシュされたトークンが返される' do
        if refresh_token.present?
          put :update, params: {}
          expect(response).to have_http_status(:success)

          json = JSON.parse(response.body)
          expect(json.size).to eq(3)
          expect(json['session_token']).not_to be_nil
          expect(json['refresh_token']).not_to be_nil
          expect(json['expired_at']).not_to be_nil
        end
      end
    end

    context 'ユーザーが削除されている' do
      before do
        if ENV['FIREBASE_UID'].present?
          create :user, { uid: ENV['FIREBASE_UID'], deleted: true }
        end
      end

      it '401エラーが返される' do
        if refresh_token.present?
          put :update, params: {}
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
