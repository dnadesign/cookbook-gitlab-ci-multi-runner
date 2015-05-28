# gitlab-ci-multi-runner cookbook

[![Circle CI](https://circleci.com/gh/dnadesign/cookbook-gitlab-ci-multi-runner.svg?style=svg)](https://circleci.com/gh/dnadesign/cookbook-gitlab-ci-multi-runner)

LWRP based cookbook to install and manage instance with gitlab-ci-multi-runner

## Supported Platforms

* debian
* ubuntu
* centos
* redhat
* amazon
* scientific
* fedora

## Usage

Include this cookbook as a dependency in the metadata of your own cookbook.
It has no recipes, so do not include it in the run_list directly.

### my_gitlab_wrapper_cookbook::default

```ruby
# my_gitlab_wrapper_cookbook/recipes/default.rb

# Install the gitlab-ci-multi-runner package
gitlab_ci_multi_runner 'gitlab-ci-multi-runner' do
  version "0.3.3"
  action [:install, :enable]
end

# Setup some runners
node.set['gitlab-ci-multi-runner']['ci_url'] = 'http://localhost:3000/ci'
node.set['gitlab-ci-multi-runner']['registration_token'] = 'deadbeef'

# A runner that will run CI tests inside a docker instance, with postgresql docker instance attached
gitlab_ci_runner 'ruby-2.2' do
  executor 'docker'
  docker_options({
    'image' => 'library/ruby:2.2',
    'postgresql' => '9.2'
  })
  tags ['ruby', 'postgresql']
end

# A runner that will run CI tests on the host machine
gitlab_ci_runner 'local' do
  executor 'shell'
end

```

## Dependencies

This cookbook requires that you already have Gitlab CI installed, as you need to provide a gitlab CI url, and runner registration token. For more info, see my gitlab-omnibus cookbook.

## License and Authors

Author:: Jeremy Olliver (<jeremy.olliver@gmail.com>)
