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

      def ci_url_value
        new_resource.ci_url || (node['gitlab-ci-multi-runner']['ci_url'] if node['gitlab-ci-multi-runner'])
      end

      def registration_token_value
        new_resource.registration_token || (node['gitlab-ci-multi-runner']['registration_token'] if node['gitlab-ci-multi-runner'])
      end

      def build_registration_options
        raise OptionValidationError, "gitlab_ci_runner needs ci_url parameter or node['gitlab-ci-multi-runner']['ci_url'] attribute set" unless ci_url_value
        raise OptionValidationError, "gitlab_ci_runner needs registration_token parameter or node['gitlab-ci-multi-runner']['registration_token'] attribute set" unless registration_token_value
        new_resource.docker_options.symbolize_keys!
        new_resource.ssh_options.symbolize_keys!

        options =  "-n -r '#{new_resource.registration_token}' -u '#{new_resource.ci_url}'"
        options += " -d '#{new_resource.description}'" if new_resource.description
        options += " -t '#{new_resource.tags.join(' ')}'" if new_resource.tags.any?
        options += " -e #{new_resource.executor}"
        if new_resource.executor == 'docker'
          raise OptionValidationError, "gitlab_ci_runner must specify docker_options: {image: 'foo/bar'} when using executor: 'docker'" unless new_resource.docker_options[:image]
          options += " --docker-image = '#{new_resource.docker_options[:image]}'"
          options += " --docker-privileged = #{new_resource.docker_options[:privileged]}" unless new_resource.docker_options[:privileged].nil?
          options += " --docker-mysql = '#{new_resource.docker_options[:mysql]}'" if new_resource.docker_options[:mysql]
          options += " --docker-postgres = '#{new_resource.docker_options[:postgres]}'" if new_resource.docker_options[:postgres]
          options += " --docker-mongo = '#{new_resource.docker_options[:mongo]}'" if new_resource.docker_options[:mongo]
          options += " --docker-redis = '#{new_resource.docker_options[:redis]}'" if new_resource.docker_options[:redis]
        end
        if new_resource.executor == 'parallels'
          raise OptionValidationError, "gitlab_ci_runner must specify parallels_vm when using executor: 'paralells'"
          options += " --parallels-vm = '#{new_resource.parallels_vm}'"
        end
        if new_resource.executor == 'ssh'
          raise OptionValidationError, "gitlab_ci_runner must specify ssh_options: {host: 'example.com'} when using executor: 'ssh'" unless new_resource.ssh_options[:host]
          options += " --ssh-host = '#{new_resource.ssh_options[:host]}'"
          options += " --ssh-port = '#{new_resource.ssh_options[:port]}'" if new_resource.ssh_options[:port]
          options += " --ssh-user = '#{new_resource.ssh_options[:user]}'" if new_resource.ssh_options[:user]
          options += " --ssh-password = '#{new_resource.ssh_options[:password]}'" if new_resource.ssh_options[:password]
        end
        options += " #{new_resource.name}"

        return options
      end

    end
  end
end
