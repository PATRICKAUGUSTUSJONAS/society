module Society

  class Parser

    def self.for_files(file_path)
      new(::Analyst.for_files(file_path))
    end

    def self.for_source(source)
      new(::Analyst.for_source(source))
    end

    attr_reader :analyzer

    def initialize(analyzer)
      @analyzer = analyzer
    end

    def report(format, output_path='./doc/society')
      raise(ArgumentError, "Unknown format #{format}") unless formatter = FORMATTERS[format]
      formatter.new(
        json_data: json_data,
        output_path: output_path
      ).write
    end

    def all_the_data
      {
        classes: analyzer.classes,
        resolved: {
          associations: @association_processor.associations,
          references: @reference_processor.references
        },
        unresolved: unresolved_edges,
        stats: {
          resolved_associations: @association_processor.associations.size,
          unresolved_associations: @association_processor.unresolved_associations.size,
          resolved_references: @reference_processor.references.size,
          unresolved_references: @reference_processor.unresolved_references.size
        }
      }
    end

    private

    FORMATTERS = {
      html: Society::Formatter::Report::HTML,
      json: Society::Formatter::Report::Json
    }

    def classes
      @classes ||= analyzer.classes
    end

    def class_graph
      @class_graph ||= begin
        associations = associations_from(classes) + references_from(classes)
        # TODO: merge identical classes, and (somewhere else) deal with
        #       identical associations too. need a WeightedEdge, and each
        #       one will be unique on [from, to], but will have a weight

        ObjectGraph.new(nodes: classes, edges: associations)
      end
    end

    def json_data
      Society::Formatter::Graph::JSON.new(class_graph).to_json
    end

    # TODO: this is dumb, cuz it depends on class_graph to be called first,
    #       but i'm just doing it for debugging right now, so LAY OFF ME
    def unresolved_edges
      {
        associations: @association_processor.unresolved_associations,
        references: @reference_processor.unresolved_references
      }
    end

    def associations_from(all_classes)
      @association_processor ||= AssociationProcessor.new(all_classes)
      @association_processor.associations
    end

    def references_from(all_classes)
      @reference_processor ||= ReferenceProcessor.new(all_classes)
      @reference_processor.references
    end

  end

end

