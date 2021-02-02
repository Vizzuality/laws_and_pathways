require 'rails_helper'

RSpec.describe Admin::TestimonialsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:testimonial) { create(:testimonial) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: testimonial.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: testimonial.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :testimonial,
          author: 'My amazing author',
          quote: 'Test quote'
        )
      end

      subject { post :create, params: {testimonial: valid_params} }

      it 'creates a new Testimonial' do
        expect { subject }.to change(Testimonial, :count).by(1)

        last_testimonial_created.tap do |g|
          expect(g.author).to eq(valid_params[:author])
          expect(g.quote).to eq(valid_params[:quote])
        end
      end

      it 'redirects to the created Testimonial' do
        expect(subject).to redirect_to(admin_testimonial_path(Testimonial.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:testimonial, author: nil) }

      subject { post :create, params: {testimonial: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Testimonial' do
        expect { subject }.not_to change(Testimonial, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:testimonial_to_update) { create(:testimonial) }

    context 'with valid params' do
      let(:valid_update_params) { {author: 'author was updated'} }

      subject { patch :update, params: {id: testimonial_to_update.id, testimonial: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Testimonial, :count)
      end

      it 'updates existing Testimonial' do
        expect { subject }.to change { testimonial_to_update.reload.author }.to('author was updated')
      end

      it 'redirects to the updated Testimonial' do
        expect(subject).to redirect_to(admin_testimonial_path(testimonial_to_update))
      end
    end
  end

  def last_testimonial_created
    Testimonial.order(:created_at).last
  end
end
