node.set['gitlab-ci-multi-runner']['ci_url'] = 'http://localhost:3000/ci'
node.set['gitlab-ci-multi-runner']['registration_token'] = 'deadbeef'

gitlab_ci_runner 'ssh-example' do
  executor 'ssh'
end
