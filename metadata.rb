name             'gitlab-ci-multi-runner'
maintainer       'Jeremy Olliver'
maintainer_email 'jeremy.olliver@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures gitlab-ci-multi-runner'
long_description 'Installs/Configures gitlab-ci-multi-runner'
version          '0.1.0'

['debian', 'ubuntu', 'centos', 'redhat', 'amazon', 'scientific', 'fedora'].each do |platform|
  supports platform
end

depends 'packagecloud', '~> 0.0.18'
recommends 'docker'

# recommends 'gitlab-omnibus'
