require 'rspec_api_blueprint/spec_blueprint_resource'

class SpecBlueprintGroup
  attr_accessor :name, :resources

  def initialize(name, order = 0)
    @name = name
    @order = format('%02d', order)
    @resources = {}
  end

  def to_s
    return unless @resources.any?
    @resources.values.map(&:to_s).join
  end

  def file_path
    file_name = @name.tr(' ', '').underscore
    "#{api_docs_folder_path}#{@order}_#{file_name}_blueprint.md"
  end
end
