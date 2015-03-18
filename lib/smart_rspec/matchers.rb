require 'smart_rspec/support/regexes'
require 'smart_rspec/matchers/be_matchers'
require 'smart_rspec/matchers/other_matchers'

module SmartRspec
  module Matchers
    include SmartRspec::Support::Regexes
    include SmartRspec::Matchers::BeMatchers
    include SmartRspec::Matchers::OtherMatchers
  end
end

