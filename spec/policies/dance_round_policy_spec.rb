require 'rails_helper'

describe DanceRoundPolicy do

  let(:guest) { mock_model User }
  let(:observer) { mock_model User }
  let(:dance_judge) { mock_model User }
  let(:acrobatics_judge) { mock_model User }
  let(:admin) { mock_model User }
  let(:round) { mock_model Round }
  let(:dance_round) { mock_model DanceRound, round: round }
  subject { DanceRoundPolicy }

  before do
    [acrobatics_judge, admin, dance_judge, guest, observer].each do |user|
      allow(user).to receive(:has_role?).and_return(false)
    end
    [acrobatics_judge, dance_judge, observer].each do |user|
      allow(user).to receive(:has_role?).with(:judge).and_return(true)
    end
    allow(observer).to receive(:has_role?).with(:observer, round).and_return(true)
    allow(dance_judge).to receive(:has_role?).with(:dance_judge, round).and_return(true)
    allow(acrobatics_judge).to receive(:has_role?).with(:acrobatics_judge, round).and_return(true)
    allow(admin).to receive(:has_role?).with(:admin).and_return(true)
  end

  permissions :create? do
    it 'permits observers to start a dance round' do
      expect(subject).to permit(observer, dance_round)
    end

    %w(acrobatics_judge admin dance_judge guest).each do |user_type|
      it "denies any #{user_type} to start a dance round" do
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end
  end

  permissions :show? do
    %w(acrobatics_judge dance_judge observer).each do |user_type|
      it "permits #{user_type}s to show a dance round" do
        expect(subject).to permit(send(user_type), dance_round)
      end
    end

    %w(admin guest).each do |user_type|
      it "denies any #{user_type} to show a dance round" do
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end
  end

  permissions :admin_show? do
    %w(admin).each do |user_type|
      it "permits #{user_type}s to show a dance round" do
        expect(subject).to permit(send(user_type), dance_round)
      end
    end

    %w(acrobatics_judge dance_judge guest observer).each do |user_type|
      it "denies any #{user_type} to show a dance round" do
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end
  end

  permissions :update? do
    %w(acrobatics_judge dance_judge observer).each do |user_type|
      before do
        allow(send(user_type)).to receive(:rated?).with(dance_round).and_return(false)
      end

      it "permits #{user_type}s to update a dance round" do
        expect(subject).to permit(send(user_type), dance_round)
      end

      it "checks if #{user_type} has rated already" do
        expect(send(user_type)).to receive(:rated?).with(dance_round)
        subject.new(send(user_type), dance_round).public_send(:update?)
      end

      it "checks if #{user_type}'s rating was reopened if rated already" do
        allow(send(user_type)).to receive(:rated?).with(dance_round).and_return(true)
        expect(dance_round).to receive(:reopened_for?).with(send(user_type)).and_return(true)
        subject.new(send(user_type), dance_round).public_send(:update?)
      end

      it "permits #{user_type} if user already rated and user's rating was reopened" do
        allow(send(user_type)).to receive(:rated?).with(dance_round).and_return(true)
        allow(dance_round).to receive(:reopened_for?).with(send(user_type)).and_return(true)
        expect(subject).to permit(send(user_type), dance_round)
      end

      it "denies #{user_type} to update dance_round if user already rated and user's rating was not reopened" do
        allow(send(user_type)).to receive(:rated?).with(dance_round).and_return(true)
        allow(dance_round).to receive(:reopened_for?).with(send(user_type)).and_return(false)
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end

    %w(admin guest).each do |user_type|
      it "denies any #{user_type} to update a dance round" do
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end
  end

  permissions :accept? do
    it "checks if all of observer's judges have voted" do
      expect(dance_round).to receive(:ready?).with(observer)
      subject.new(observer, dance_round).public_send(:accept?)
    end

    it 'permits observers to accept a dance round if all their judges have voted' do
      allow(dance_round).to receive(:ready?).with(observer).and_return(true)
      expect(subject).to permit(observer, dance_round)
    end

    it 'denies observers to accept a dance round if any of their judges did not vote' do
      allow(dance_round).to receive(:ready?).with(observer).and_return(false)
      expect(subject).not_to permit(observer, dance_round)
    end

    %w(acrobatics_judge admin dance_judge guest).each do |user_type|
      it "denies any #{user_type} to show a dance round" do
        expect(subject).not_to permit(send(user_type), dance_round)
      end
    end
  end
end
