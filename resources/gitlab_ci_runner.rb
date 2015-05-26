actions [:create, :delete, :verify]
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :default => nil
attribute :registration_token, :kind_of => String, :required => true
attribute :ci_url, :kind_of => String, :required => true
attribute :description, :kind_of => String
attribute :tags, :kind_of => Array
attribute :executor, :kind_of => String, :equal_to => ['shell', 'docker', 'ssh', 'parallels'], :default => 'shell'
attribute :docker_options, :kind_of => Hash
attribute :ssh_options, :kind_of => Hash
attribute :parallels_vm, :kind_of => String

attribute :bin_command, :kind_of => String, :default => 'gitlab-ci-multi-runner'
