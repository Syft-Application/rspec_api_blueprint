require 'rspec_api_blueprint/spec_blueprint_action'

class SpecBlueprintResource
  attr_accessor :name, :actions, :description

  def initialize(name, description)
    @name = name
    @description = description
    @actions = {}
  end

  def to_s
    "## #{description} [#{name}]\n#{render_actions}"
  end

  private

  def render_actions
    actions.values.join("\n")
  end
end
