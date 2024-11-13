require_relative "converter/elements"
require_relative "converter/elements/root"
require_relative "converter/elements/base"
require_relative "converter/elements/introduction"
require_relative "converter/elements/section"

module Obp
  module Access
    class Converter
      attr_reader :urn, :source

      def initialize(urn:, source:)
        @urn = urn
        @source = source
      end

      def to_xml
        root = Elements::Root.new(urn:)
        doc = Nokogiri::XML(root.to_xml)

        nodes.map do |node|
          Elements.descendants.map do |descendant|
            element = descendant.new(doc:, node:)
            next unless element.match_node?

            element.render
          end
        end

        doc.root.to_xml
      end

      private

      def nodes
        html = source.gsub(160.chr("UTF-8"), " ") # Convert NBSP to spaces from html
        doc = Nokogiri::HTML(html)
        doc.css("body > div.sts-standard > div.sts-section") # Find all direct sections from HTML
      end
    end
  end
end