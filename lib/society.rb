require "analyst"
require "fileutils"
require "active_support/core_ext/string/inflections"

require_relative "society/cli"
require_relative "society/association_processor"
require_relative "society/reference_processor"
require_relative "society/edge"
require_relative "society/formatter/core"
require_relative "society/formatter/heatmap"
require_relative "society/formatter/network"
require_relative "society/object_graph"
require_relative "society/parser"
require_relative "society/version"

module Society

  def self.new(*path, formatter=:html)
    Society::Parser.new(path_to_files, formatter)
  end

  def self.analyze_classes(*path)
    parser = Society::Parser.for_files(*path)
    graph = parser.class_graph
    heatmap_json = parser.formatters(graph).heatmap.to_json
    network_json = parser.formatters(graph).network.to_json

end



    # graph = parser.class_graph
    # heatmap_json = parser.formatters(graph).heatmap.to_json
    # network_json = parser.formatters(graph).network.to_json
    # formatter = Formatter::HTML.new(
    #   heatmap_json: heatmap_json,
    #   network_json: network_json,
    #   data_dir: File.join(File.dirname(__FILE__), '..', 'doc', 'data')
    # )
    # formatter.write
    # parser.all_the_data
