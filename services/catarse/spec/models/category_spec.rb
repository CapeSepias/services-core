# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  include Chewy::Rspec::Helpers

  let(:category) { create(:category) }
  let(:category_2) { create(:category) }

  describe 'Associations' do
    before do
      category
    end

    it { is_expected.to have_many :projects }
    it { is_expected.to validate_presence_of :name_pt }
    it { is_expected.to validate_uniqueness_of :name_pt }
  end

  describe '#with_projects_on_this_week' do
    let(:category_1) { create(:category) }
    let(:category_2) { create(:category) }
    let(:category_3) { create(:category) }

    subject { Category.with_projects_on_this_week.order(id: :asc) }

    before do
      3.times { create_project({ category: category_1 }, { to_state: 'online' }) }
      4.times { create_project({ category: category_2 }, { to_state: 'online' }) }
      5.times { create_project({ category: category_3 }, { to_state: 'online', created_at: 2.weeks.ago }) }
    end

    it { is_expected.to eq([category_1, category_2]) }
  end

  describe '#with_projects' do
    before do
      create(:project, category: category, state: 'online')
      create(:project, category: category, state: 'successful')
      create(:project, category: category_2, state: 'draft')
      create(:project, category: category_2, state: 'rejected')
    end

    subject { Category.with_projects }

    it 'should return only categories that have a least one project (online, successful, failed or waiting_funds)' do
      expect(subject.count).to eq(1)
    end
  end

  describe '.deliver_projects_of_week_notification' do
    let(:category) { create(:category) }
    let(:user) { create(:user) }

    before do
      category.users << user
    end

    context "when user don't have received the notification of this week" do
      before do
        expect(category).to receive(:notify).with(:categorized_projects_of_the_week, user, category).and_call_original
        category.deliver_projects_of_week_notification
      end

      it do
        expect(category.notifications.where(template_name: 'categorized_projects_of_the_week').count).to eq 1
      end
    end

    context 'when user already received the notification of this week' do
      before do
        category.deliver_projects_of_week_notification
        category.reload
        category.deliver_projects_of_week_notification
      end

      it do
        expect(category.notifications.where(template_name: 'categorized_projects_of_the_week').count).to eq 1
      end
    end
  end

  describe 'project_index' do
    let(:hits) do
      [
        {
          '_index' => 'projects',
          '_type' => '_doc',
          '_id' => '1',
        }
      ]
    end

    let(:raw_response) do
      {
        'took' => 4,
        'hits' => {
          'total' => {
            'value' => 1,
            'relation' => 'eq'
          },
          'max_score' => 1.0,
          'hits' => hits
        }
      }
    end

    context 'when category is updated' do
      let(:category) { create(:category) }
      let!(:project) { create(:project, category: category) }

      it 'updates project index' do
        mock_elasticsearch_response(ProjectsIndex, raw_response) do
          expect(category.update!(name_pt: 'test')).to update_index(ProjectsIndex)
        end
      end
    end
  end
end
