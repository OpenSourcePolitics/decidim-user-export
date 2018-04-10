# frozen_string_literal: true
require "decidim/export/admin"
require "decidim/export/engine"
require "decidim/export/admin_engine"
require "decidim/export/component"
require 'csv'
require 'rails/all'

module Decidim
  # Base module for this engine.
  module Export
    class Csv
      def initialize(data, attributes)
        @data = data
        @attributes = attributes
      end

      def export
        CSV.generate(headers: true) do |csv|
          csv << @attributes
          @data.each do |data|
            csv << @attributes.map{ |attr| data.send(attr) }
          end
        end
      end
    end
  end
end
