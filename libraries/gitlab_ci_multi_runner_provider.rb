class Chef
  class Provider
    class GitlabCiMultiRunner < Chef::Provider::LWRPBase

      def whyrun_supported?
        true
      end

      use_inline_resources if defined?(use_inline_resources)

      action :install do

        case node['platform']
        when 'debian', 'ubuntu'
          package_cloud_type = 'deb'
        when 'centos', 'redhat', 'amazon', 'scientific', 'fedora'
          package_cloud_type = 'rpm'
        else
          Chef::Log.error("Could not detect compatible package format for gitlab - please specify `['gitlab']['package_format']` as either 'deb' or 'rpm'")
        end

        packagecloud_repo "runner/gitlab-ci-multi-runner" do
          base_url new_resource.repo_base_url
          type(package_cloud_type) if package_cloud_type
        end

        package new_resource.package_name do
          version(new_resource.version) if new_resource.version
          action :upgrade
        end

      end

      action :enable do
        run_multirunner_cmd('install', true) # install service handlers
        service 'gitlab-ci-multi-runner' do
          action [:start, :enable]
        end
      end

      action :disable do
        service 'gitlab-ci-multi-runner' do
          action [:disable]
        end
        # run_multirunner_cmd('uninstall')
      end

      action :start do
        run_multirunner_cmd('start')
      end

      action :stop do
        run_multirunner_cmd('stop')
      end

      action :restart do
        run_multirunner_cmd('restart')
      end

      action :reload do
        run_multirunner_cmd('restart')
      end


      private

      def run_multirunner_cmd(cmd, ignore_errors = false)
        command_string = "#{new_resource.bin_command} #{cmd}"
        ruby_block "#{new_resource.package_name}-#{cmd}" do
          block do
            if ignore_errors
              shell_out(command_string)
            else
              shell_out!(command_string)
            end
          end
        end
      end

    end
  end
end
