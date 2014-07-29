#!/usr/bin/env ruby
require 'fileutils'

require File.expand_path(File.join(File.dirname(__FILE__), 'ci-helpers'))

working_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))

uninstall_gem('calabash-cucumber')


Dir.chdir working_dir do

  do_system('rm -rf calabash-ios')

  do_system('git clone --recursive https://github.com/calabash/calabash-ios')

  do_system('rm -rf animated-happiness')

  do_system('git clone --recursive https://github.com/jmoody/animated-happiness.git')

  # if calabash.framework exists, it was built in another step
  unless File.exist?('calabash.framework')
    do_system('make')
  end

end

calabash_gem_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'calabash-ios'))
calabash_framework = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'calabash.framework'))

Dir.chdir calabash_gem_dir do

  do_system('script/ci/travis/install-static-libs.rb')

  do_system('script/ci/travis/bundle-install.rb')

  do_system('script/ci/travis/install-gem-ci.rb')

end

chou_working_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'animated-happiness/chou'))

FileUtils.rm_rf("#{chou_working_dir}/calabash.framework")
FileUtils.cp_r(calabash_framework, chou_working_dir)

Dir.chdir chou_working_dir do

  do_system('rm -rf Gemfile*')
  do_system('rm -rf .bundle')

  File.open('Gemfile', 'w') do |file|
    file.write("source 'https://rubygems.org'\n")
    file.write("gem 'calabash-cucumber', :github => 'calabash/calabash-ios', :branch => 'master'\n")
    file.write("gem 'xcpretty', '~> 0.1'\n")
  end

  FileUtils.mkdir_p('.bundle')

  File.open('.bundle/config', 'w') do |file|
    file.write("---\n")
    file.write("BUNDLE_LOCAL__CALABASH-CUCUMBER: \"#{calabash_gem_dir}\"\n")
  end
end

animated_happiness_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'animated-happiness'))

Dir.chdir animated_happiness_dir do

  do_system('script/ci/travis/build-and-stage-app.sh')

  do_system('script/ci/travis/cucumber-ci.rb --tags ~@no_ci')
end
