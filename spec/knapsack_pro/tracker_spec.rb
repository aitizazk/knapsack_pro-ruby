shared_examples 'default trakcer attributes' do
  it { expect(tracker.global_time).to eql 0 }
  it { expect(tracker.test_files_with_time).to eql({}) }
end

describe KnapsackPro::Tracker do
  let(:tracker) { described_class.send(:new) }

  it_behaves_like 'default trakcer attributes'

  describe '#current_test_path' do
    subject { tracker.current_test_path }

    context 'when current_test_path not set' do
      it do
        expect { subject }.to raise_error("current_test_path needs to be set by Knapsack Pro Adapter's bind method")
      end
    end

    context 'when current_test_path set' do
      context 'when current_test_path has prefix ./' do
        before { tracker.current_test_path = './spec/models/user_spec.rb' }
        it { should eql 'spec/models/user_spec.rb' }
      end

      context 'when current_test_path has no prefix ./' do
        before { tracker.current_test_path = 'spec/models/user_spec.rb' }
        it { should eql 'spec/models/user_spec.rb' }
      end
    end
  end

  describe 'track time execution' do
    let(:test_paths) { ['a_spec.rb', 'b_spec.rb'] }
    let(:delta) { 0.02 }

    shared_examples 'test tracker' do
      it { expect(tracker.global_time).to be_within(delta).of(0.3) }
      it { expect(tracker.test_files_with_time.keys.size).to eql 2 }
      it { expect(tracker.test_files_with_time['a_spec.rb']).to be_within(delta).of(0.1) }
      it { expect(tracker.test_files_with_time['b_spec.rb']).to be_within(delta).of(0.2) }
    end

    context 'without Timecop' do
      before do
        test_paths.each_with_index do |test_path, index|
          tracker.current_test_path = test_path
          tracker.start_timer
          sleep index.to_f / 10 + 0.1
          tracker.stop_timer
        end
      end

      it { expect(tracker.global_time).to be_within(delta).of(0.3) }
      it { expect(tracker.test_files_with_time.keys.size).to eql 2 }
      it { expect(tracker.test_files_with_time['a_spec.rb']).to be_within(delta).of(0.1) }
      it { expect(tracker.test_files_with_time['b_spec.rb']).to be_within(delta).of(0.2) }
    end

    context "with Timecop - Timecop shouldn't have impact on measured test time" do
      let(:now) { Time.now }

      before do
        test_paths.each_with_index do |test_path, index|
          Timecop.freeze(now) do
            tracker.current_test_path = test_path
            tracker.start_timer
          end

          delay = index + 1
          Timecop.freeze(now+delay) do
            tracker.stop_timer
          end
        end
      end

      it { expect(tracker.global_time).to be > 0 }
      it { expect(tracker.global_time).to be_within(delta).of(0) }
      it { expect(tracker.test_files_with_time.keys.size).to eql 2 }
      it { expect(tracker.test_files_with_time['a_spec.rb']).to be_within(delta).of(0) }
      it { expect(tracker.test_files_with_time['b_spec.rb']).to be_within(delta).of(0) }
    end
  end

  describe '#reset!' do
    before do
      tracker.current_test_path = 'a_spec.rb'
      tracker.start_timer
      sleep 0.1
      tracker.stop_timer
      expect(tracker.global_time).not_to eql 0
      tracker.reset!
    end

    it_behaves_like 'default trakcer attributes'
  end
end
