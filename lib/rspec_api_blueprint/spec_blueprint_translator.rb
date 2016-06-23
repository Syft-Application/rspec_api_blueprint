require 'rspec_api_blueprint/spec_blueprint_group'

class SpecBlueprintTranslator
  class << self
    def begin
      @groups = {}
    end

    def record_example(example, request, response)
      group_metas = example_group_metas(example)

      return unless group_metas.count >= 3 &&
                    example.metadata[:document] == true

      name = group_name(group_metas[-1])

      order = File.basename("./#{example.metadata[:absolute_file_path].split('/').last}")
                  .split('_')
                  .first
                  .to_i
      group = (@groups[name] ||= SpecBlueprintGroup.new(name, order))

      name = resource_name(group_metas[-2])
      resource = (group.resources[name] ||= SpecBlueprintResource.new(name, resource_description(group_metas[-2])))

      request_method = request_method(group_metas)
      action = (resource.actions[request_method] ||= SpecBlueprintAction.new(request_method,
                                                                             action_indentifier(group_metas)))
      action.add_transaction_example request, response, example.metadata[:as]
    end

    def end
      write_resources
    end

    private

    def example_group_metas(example)
      group_metas = []
      group_meta = example.example_group.metadata

      while group_meta.present?
        group_metas << group_meta
        group_meta = group_meta[:parent_example_group]
      end
      group_metas
    end

    def write_resources
      @groups.each do |_, group|
        File.open(group.file_path, 'w+') do |handle|
          handle.write group.to_s
        end
      end
    end

    def group_name(group)
      group[:description_args].first.match(/(.+)\sRequests/)
      Regexp.last_match(1)
    end

    def resource_name(group)
      group[:description_args].first.match(/(.+)\[(.+)\]/)
      Regexp.last_match(2)
    end

    def resource_description(group)
      group[:description_args].first.match(/(.+)\[(.+)\]/)
      Regexp.last_match(1)
    end

    def request_method(group_metas)
      match_string = group_metas[-3][:description_args].first
      unless match_string.kind_of? String
        raise Exceptions::SpecFormattingError.new("#{match_string} must be a string")
      end
      match_string.match(/(\w+)\s(.+)/)
      Regexp.last_match(1)
    end

    def action_indentifier(group_metas)
      group_metas[-3][:description_args].first.match(/(\w+)\s(.+)/)
      Regexp.last_match(2)
    end
  end
end
