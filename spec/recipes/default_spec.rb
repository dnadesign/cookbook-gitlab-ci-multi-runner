require_relative '../spec_helper'

describe 'gitlab-ci-multi-runner LWRP' do
  let(:chef_run) { ChefSpec::SoloRunner.converge('multirunner_test::default') }

  it 'installs gitlab-ci-multi-runner package' do
    expect(chef_run).to install_gitlab_ci_multi_runner('gitlab-ci-multi-runner').with_version("0.3.3")
  end

  it 'enables gitlab-ci-multi-runner package' do
    expect(chef_run).to enable_gitlab_ci_multi_runner('gitlab-ci-multi-runner')
  end
end
