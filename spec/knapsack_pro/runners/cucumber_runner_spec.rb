require 'cucumber/rake/task'

describe KnapsackPro::Runners::CucumberRunner do
  subject { described_class.new(KnapsackPro::Adapters::CucumberAdapter) }

  it { should be_kind_of KnapsackPro::Runners::BaseRunner }

  describe '.run' do
    let(:args) { '--custom-arg' }

    subject { described_class.run(args) }

    let(:test_suite_token_cucumber) { 'fake-token' }
    let(:test_dir) { 'fake-test-dir' }
    let(:stringify_test_file_paths) { 'features/fake1.scenario features/fake2.scenario' }
    let(:runner) do
      instance_double(described_class,
                      test_dir: test_dir,
                      stringify_test_file_paths: stringify_test_file_paths)
    end
    let(:task) { double }

    subject { described_class.run(args) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:test_suite_token_cucumber).and_return(test_suite_token_cucumber)

      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_TEST_SUITE_TOKEN', test_suite_token_cucumber)
      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_RECORDING_ENABLED', 'true')

      expect(described_class).to receive(:new)
      .with(KnapsackPro::Adapters::CucumberAdapter).and_return(runner)

      expect(Rake::Task).to receive(:[]).with('knapsack_pro:cucumber_run').at_least(1).and_return(task)

      t = double
      expect(Cucumber::Rake::Task).to receive(:new).with('knapsack_pro:cucumber_run').and_yield(t)
      expect(t).to receive(:cucumber_opts=).with('--custom-arg --require fake-test-dir -- features/fake1.scenario features/fake2.scenario')
    end

    context 'when task already exists' do
      before do
        expect(Rake::Task).to receive(:task_defined?).with('knapsack_pro:cucumber_run').and_return(true)
        expect(task).to receive(:clear)
      end

      it do
        result = double(:result)
        expect(task).to receive(:invoke).and_return(result)
        expect(subject).to eq result
      end
    end

    context "when task doesn't exist" do
      before do
        expect(Rake::Task).to receive(:task_defined?).with('knapsack_pro:cucumber_run').and_return(false)
        expect(task).not_to receive(:clear)
      end

      it do
        result = double(:result)
        expect(task).to receive(:invoke).and_return(result)
        expect(subject).to eq result
      end
    end
  end
end
