require_relative '../spec_helper'

describe 'gitlab_ci_runner LWRP' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['gitlab_ci_runner']) do |node|
      node.set['gitlab-ci-multi-runner']['ci_url'] = 'http://localhost:3000/ci'
      node.set['gitlab-ci-multi-runner']['registration_token'] = 'deadbeef'
    end.converge('multirunner_test::runners')
  end
  let(:runners) { ['ruby-1.9.3', 'ruby-2.1', 'local', 'coreos'] }
  before do
    runners.each do |runner_name|
      stub_command(%Q(grep 'name = "#{runner_name}"' /home/gitlab_ci_multi_runner/config.toml)).and_return(false)
    end
  end

  it 'should create all the runners' do
    runners.each do |runner|
      expect(chef_run).to create_gitlab_ci_runner(runner)
    end
  end

  it 'should contain valid defaults' do
    resource = chef_run.gitlab_ci_runner('local')
    expect(resource.bin_command).to eq('gitlab-ci-multi-runner')
    expect(resource.tags).to eq([])
    expect(resource.executor).to eq('shell')
    expect(resource.registration_token).to eq('deadbeef')
    expect(resource.ci_url).to eq('http://localhost:3000/ci')
  end

end

describe 'gitlab_ci_runner LWRP internals' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['gitlab_ci_runner']).converge('multirunner_test::runners_invalid') }

  it 'should fail' do
    expect {
      chef_run
    }.to raise_error(Chef::Provider::GitlabCiRunner::OptionValidationError)
  end
end

describe 'gitlab_ci_runner LWRP validations' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['gitlab_ci_runner']).converge('multirunner_test::runners_missing_options') }

  it 'should fail' do
    expect {
      chef_run
    }.to raise_error(Chef::Provider::GitlabCiRunner::OptionValidationError)
  end
end
