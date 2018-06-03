require 'rails_helper'

RSpec.describe UserController, type: :controller do
  describe 'DELETE #destroy' do
    let(:record) { create(:user, { uid: 'user21', name: 'ユーザー21', email: 'user21@example.com' }) }
    let(:params) { { id: record.id } }

    it 'ユーザーが無効化される' do
      delete :destroy, params: params
      expect(response).to have_http_status(:success)

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
