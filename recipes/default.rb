gitlab_ci_multi_runner do
  version node['gitlab-ci-multi-runner']['version']
  actions [:install, :enable]
end
