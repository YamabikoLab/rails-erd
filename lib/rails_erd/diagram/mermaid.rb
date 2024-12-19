# encoding: utf-8
require "rails_erd/diagram"
require "erb"

module RailsERD
  class Diagram
    class Mermaid < Diagram

      attr_accessor :graph

      setup do
        self.graph = ["classDiagram"]

        # hard code to RL to make it easier to view diagrams from GitHub
        self.graph << "\tdirection RL"
      end

      each_entity do |entity, attributes|
        # puts "Entity: #{entity.inspect}"
        # graph << "\tclass `#{entity}`"
        #
        # attributes.each do |attr|
        #   graph << "\t`#{entity}` : +#{attr.type} #{attr.name}"
        # end
        #
        # graph << "\t`#{entity}` : --"
        #
        # public_methods = entity.model.public_instance_methods(false)
        # public_methods.each do |method|
        #   graph << "\t`#{entity}` : +#{method}()"
        # end
      end

      each_specialization do |specialization|
        from, to = specialization.generalized, specialization.specialized
        graph << "\t<<polymorphic>> `#{specialization.generalized}`"
        graph << "\t #{from.name} <|-- #{to.name}"
      end

      each_relationship do |relationship|
        from, to = relationship.source, relationship.destination
        graph << "\t`#{from.name}` #{relation_arrow(relationship)} `#{to.name}`"

        from.children.each do |child|
          graph << "\t`#{child.name}` #{relation_arrow(relationship)} `#{to.name}`"
        end

        to.children.each do |child|
          graph << "\t`#{from.name}` #{relation_arrow(relationship)} `#{child.name}`"
        end
      end

      save do
        raise "Saving diagram failed!\nOutput directory '#{File.dirname(filename)}' does not exist." unless File.directory?(File.dirname(filename))

        File.write(filename.gsub(/\s/,"_"), graph.uniq.join("\n"))
        filename
      end

      def filename
        "#{options.filename}.mmd"
      end

      def relation_arrow(relationship)
        arrow_body = arrow_body relationship
        arrow_head = arrow_head relationship
        arrow_tail = arrow_tail relationship

        "#{arrow_tail}#{arrow_body}#{arrow_head}"
      end

      def arrow_body(relationship)
        relationship.indirect? ? ".." : "--"
      end

      def arrow_head(relationship)
        relationship.to_many? ?  ">" : ""
      end

      def arrow_tail(relationship)
        relationship.many_to? ? "<" : ""
      end

    end
  end
end
