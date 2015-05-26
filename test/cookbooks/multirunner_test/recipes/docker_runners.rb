gitlab_ci_runner 'ruby-1.9.3' do
  executor 'docker'
end

gitlab_ci_runner 'ruby-2.1' do
  executor 'docker'
end

gitlab_ci_runner 'local' do
  # shell
end

gitlab_ci_runner 'coreos' do
  executor 'ssh'
  ssh_options {
    host: '192.168.1.1'
    user: 'ci'
  }
end
