if defined?(ChefSpec)
  ChefSpec.define_matcher :gitlab_ci_multi_runner
  ChefSpec.define_matcher :gitlab_ci_runner

  def install_gitlab_ci_multi_runner(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:gitlab_ci_multi_runner, :install, resource_name)
  end

  def enable_gitlab_ci_multi_runner(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:gitlab_ci_multi_runner, :install, resource_name)
  end

  def create_gitlab_ci_runner(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:gitlab_ci_runner, :create, resource_name)
  end

  def delete_gitlab_ci_runner(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:gitlab_ci_runner, :delete, resource_name)
  end
end
