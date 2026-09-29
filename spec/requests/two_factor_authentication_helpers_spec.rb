require 'spec_helper'

describe 'Requests from a user who has not completed two factor authentication', type: :request do
  let(:user) { create_user }

  before { login_as user, scope: :user }

  it 'redirects HTML requests to the two factor page' do
    get secret_path

    expect(response).to redirect_to(user_two_factor_authentication_path)
  end

  it 'responds to JSON requests with 401 and the two factor path' do
    get secret_path(format: :json)

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq('redirect_to' => user_two_factor_authentication_path)
  end

  it 'responds to other formats with 401 without running the action' do
    get secret_path(format: :xml)

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).not_to include('top secret')
  end

  it 'responds with 401 when the format comes from the Accept header' do
    get secret_path, headers: { 'Accept' => 'text/csv' }

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).not_to include('top secret')
  end

  context 'when the user does not need two factor authentication' do
    before do
      allow_any_instance_of(User).to receive(:need_two_factor_authentication?).and_return(false)
    end

    it 'runs the action and sends no code' do
      get secret_path(format: :xml)

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('top secret')
      expect(SMSProvider.messages).to be_empty
    end
  end
end
