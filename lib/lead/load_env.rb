require 'dotenv'
Dotenv.load(File.join(Dir.home, '.leadrc'), '.releaserc')

require 'lead'
require 'lead/release'

version_current = Lead::Release::Version.new(Lead::VERSION)
version_required = Lead::Release::Version.new(ENV.fetch('LEAD_VERSION_REQUIRERD'))

raise "Please update to #{version_required} lead tools!" if version_required > version_current
