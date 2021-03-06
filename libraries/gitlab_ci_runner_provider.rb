# gitlab-ci-multi-runner help register
# NAME:
#    register - register a new runner

# USAGE:
#    command register [command options] [arguments...]

# OPTIONS:
#    -c, --config 'config.toml'   Config file [$CONFIG_FILE]
#    -n, --non-interactive        Run registration unattended [$REGISTER_NON_INTERACTIVE]
#    --leave-runner               Don't remove runner if registration fails [$REGISTER_LEAVE_RUNNER]
#    -r, --registration-token     Runner's registration token [$REGISTRATION_TOKEN]
#    -u, --url                    Runner URL [$CI_SERVER_URL]
#    -d, --description 'hostname' Runner's registration description [$RUNNER_DESCRIPTION]
#    -t, --tag-list               Runner's tag list separated by comma [$RUNNER_TAG_LIST]
#    -e, --executor 'shell'       Select executor, eg. shell, docker, etc. [$RUNNER_EXECUTOR]
#    --docker-image               Docker image to use (eg. ruby:2.1) [$DOCKER_IMAGE]
#    --docker-privileged          Run Docker containers in privileged mode (INSECURE) [$DOCKER_PRIVILEGED]
#    --docker-mysql               MySQL version (or specify latest) to link as service Docker service [$DOCKER_MYSQL]
#    --docker-postgres            PostgreSQL version (or specify latest) to link as service Docker service [$DOCKER_POSTGRES]
#    --docker-mongo               MongoDB version (or specify latest) to link as service Docker service [$DOCKER_MONGO]
#    --docker-redis               Redis version (or specify latest) to link as service Docker service [$DOCKER_REDIS]
#    --parallels-vm               Parallels VM to use (eg. Ubuntu Linux) [$PARALLELS_VM]
#    --ssh-host                   SSH server address (eg. my.server.com) [$SSH_HOST]
#    --ssh-port                   SSH server port (default. 22) [$SSH_PORT]
#    --ssh-user                   SSH client user [$SSH_USER]
#    --ssh-password               SSH client password [$SSH_USER]

class Chef
  class Provider
    class GitlabCiRunner < Chef::Provider::LWRPBase

      def whyrun_supported?
        true
      end

      use_inline_resources if defined?(use_inline_resources)

      action :create do
        command_string = "#{new_resource.bin_command} register #{build_registration_options}"
        execute "gitlab-ci-multirunner-register-#{new_resource.name}" do
          command command_string
          not_if %Q(grep 'name = "#{new_resource.name}"' /home/gitlab_ci_multi_runner/config.toml)
        end
      end

      action :delete do
        command_string = "#{new_resource.bin_command} unregister -n -r '#{new_resource.registration_token}' -u '#{new_resource.ci_url}'"
        execute "gitlab-ci-multirunner-unregister-#{new_resource.name}" do
          command command_string
          only_if %Q(grep 'name = "#{new_resource.name}"' /home/gitlab_ci_multi_runner/config.toml)
        end
      end

      class OptionValidationError < RuntimeError
        def initialize(*args)
          super(args)
        end
      end

      private

      def build_registration_options
        raise OptionValidationError, "gitlab_ci_runner needs ci_url parameter or node['gitlab-ci-multi-runner']['ci_url'] attribute set" unless new_resource.ci_url
        raise OptionValidationError, "gitlab_ci_runner needs registration_token parameter or node['gitlab-ci-multi-runner']['registration_token'] attribute set" unless new_resource.registration_token
        docker_options = Mash.new(new_resource.docker_options)#.symbolize_keys!
        ssh_options = Mash.new(new_resource.ssh_options)#.symbolize_keys!

        options =  "-n -r '#{new_resource.registration_token}' -u '#{new_resource.ci_url}'"
        options += " -d '#{new_resource.description}'" if new_resource.description
        options += " -t '#{new_resource.tags.join(' ')}'" if new_resource.tags.any?
        options += " -e #{new_resource.executor}"
        if new_resource.executor == 'docker'
          raise OptionValidationError, "gitlab_ci_runner must specify docker_options: {image: 'foo/bar'} when using executor: 'docker'" unless docker_options[:image]
          options += " --docker-image = '#{docker_options[:image]}'"
          options += " --docker-privileged = #{docker_options[:privileged]}" unless docker_options[:privileged].nil?
          options += " --docker-mysql = '#{docker_options[:mysql]}'" if docker_options[:mysql]
          options += " --docker-postgres = '#{docker_options[:postgres]}'" if docker_options[:postgres]
          options += " --docker-mongo = '#{docker_options[:mongo]}'" if docker_options[:mongo]
          options += " --docker-redis = '#{docker_options[:redis]}'" if docker_options[:redis]
        end
        if new_resource.executor == 'parallels'
          raise OptionValidationError, "gitlab_ci_runner must specify parallels_vm when using executor: 'paralells'"
          options += " --parallels-vm = '#{new_resource.parallels_vm}'"
        end
        if new_resource.executor == 'ssh'
          raise OptionValidationError, "gitlab_ci_runner must specify ssh_options: {host: 'example.com'} when using executor: 'ssh'" unless ssh_options[:host]
          options += " --ssh-host = '#{ssh_options[:host]}'"
          options += " --ssh-port = '#{ssh_options[:port]}'" if ssh_options[:port]
          options += " --ssh-user = '#{ssh_options[:user]}'" if ssh_options[:user]
          options += " --ssh-password = '#{ssh_options[:password]}'" if ssh_options[:password]
        end
        options += " #{new_resource.name}"

        return options
      end

    end
  end
end
