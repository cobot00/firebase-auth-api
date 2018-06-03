require 'rails_helper'

RSpec.describe UserController, type: :controller do
  before(:all) do
    create(:user, { uid: 'user01', name: 'ユーザー01', email: 'user01@example.com' })
  end

  before do
    result = JwtWrapper.encode('user01', 1)
    request.env['HTTP_AUTHORIZATION'] = 'Bearer ' + result[:jwt]
  end

  describe 'GET #current' do
    it 'ユーザー情報が返される' do
      get :current
      expect(response).to be_successful

      json = JSON.parse(response.body)
      { id: 1, name: 'ユーザー01', email: 'user01@example.com' }
        .each { |k, v| expect(json[k.to_s]).to eq v }
    end

    context '指定したidのレコードが存在しない場合' do
      before do
        result = JwtWrapper.encode('user00', 0)
        request.env['HTTP_AUTHORIZATION'] = 'Bearer ' + result[:jwt]
      end

      it '例外が発生し、エラーメッセージが返される' do
        put :current
        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body, { symbolize_names: true })
        expect(json[:message]).to eq '対象のデータが存在しません。'
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:record) { create(:user, { uid: 'user21', name: 'ユーザー21', email: 'user21@example.com' }) }
    let(:params) { { id: record.id } }

    it 'ユーザーが無効化される' do
      delete :destroy, params: params
      expect(response).to be_successful

      record.reload
      expect(record.deleted).to be_truthy
    end

    context '指定したidのレコードが存在しない場合' do
      it '例外が発生し、エラーメッセージが返される' do
        delete :destroy, params: { id: 0 }
        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body, { symbolize_names: true })
        expect(json[:message]).to eq '対象のデータが存在しません。'
      end
    end

    context '無効化されているレコードのidを指定した場合' do
      let(:record) { create(:user, { uid: 'user99', name: 'ユーザー99', email: 'user99@example.com', deleted: true }) }
      let(:params) { { id: record.id } }

      it '例外が発生し、エラーメッセージが返される' do
        delete :destroy, params: { id: record.id }
        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body, { symbolize_names: true })
        expect(json[:message]).to eq '対象のデータが存在しません。'
      end
    end
  end
end
