require_relative './helpers.rb'
require_relative './options.rb'

module Datura::Elasticsearch

  # clear data from the index (leaves index schema intact)
  module Data
  end

  # manage the aliases used to refer to specific indexes
  module Alias
  end

  # manage the creation / deletion / schema configuration of indexes
  class Index
  end

end
