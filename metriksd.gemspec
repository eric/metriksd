## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'metriksd'
  s.version           = '0.5.7'
  s.date              = '2015-03-04'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Server for handling metrics from metriks"
  s.description = ""

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Eric Lindvall"]
  s.email    = 'eric@sevenscale.com'
  s.homepage = 'https://github.com/eric/metriks_server'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## If your gem includes any executables, list them here.
  s.executables = ["metriksd"]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('librato-metrics', [ '>= 0.7', '< 2.0' ])
  s.add_dependency('msgpack', '~> 0.4')
  s.add_dependency('snappy')
  s.add_dependency('activesupport')
  s.add_dependency('eventmachine', '~> 1.0')

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('metriksd_reporter')

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE
    README.md
    Rakefile
    bin/metriksd
    examples/config.yml
    lib/metriksd.rb
    lib/metriksd/cli.rb
    lib/metriksd/config.rb
    lib/metriksd/data.rb
    lib/metriksd/librato_metrics_reporter.rb
    lib/metriksd/librato_metrics_reporter/timeslice_rollup.rb
    lib/metriksd/registry.rb
    lib/metriksd/timeslice.rb
    lib/metriksd/udp_server.rb
    metriksd.gemspec
    test/config_test.rb
    test/librato_metrics_reporter_test.rb
    test/metriksd_reporter_test.rb
    test/test_helper.rb
    test/udp_server_test.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
