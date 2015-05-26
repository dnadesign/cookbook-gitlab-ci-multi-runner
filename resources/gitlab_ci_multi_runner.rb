actions [:install, :enable, :disable, :start, :stop, :reload, :restart]
default_action :install
state_attrs :installed

attribute :package_name, :kind_of => String, :name_attribute => true, :default => 'gitlab-ci-multi-runner'
attribute :version, :kind_of => String, :default => nil
attribute :package_repo, :kind_of => String, :default => 'runner/gitlab-ci-multi-runner'
attribute :repo_base_url, :kind_of => String, :default => 'https://packages.gitlab.com'

# Attributes for reconfigure step
attribute :bin_command, :kind_of => String, :default => 'gitlab-ci-multi-runner'
# Attributes for package download
attribute :installed, :kind_of => [TrueClass, FalseClass, NilClass], :default => false
