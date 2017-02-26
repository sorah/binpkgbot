require 'binpkgbot/utils'
require 'binpkgbot/tasks'
require 'yaml'

module Binpkgbot
  class Config
    def self.from_yaml(yaml)
      new(YAML.load(yaml))
    end

    def self.load_yaml(path)
      new(YAML.load_file(path))
    end

    def initialize(doc={})
      @doc = Utils.symbolize_keys(doc)
    end

    def stage
      @doc[:stage]
    end

    def etc_portage
      @doc[:etc_portage]
    end

    def portage_repo
      @doc[:portage_repo]
    end

    def emerge_options
      @doc[:emerge_options]
    end

    def binds
      @doc[:binds]
    end

    def tasks
      (@doc[:tasks] || []).map do |defi|
        Tasks.from_definition(defi, config: self)
      end
    end

    def config_protect_mask?
      @doc.key?(:config_protect_mask)
    end

    def config_protect_mask
      @doc[:config_protect_mask]
    end

    def use_sudo_for_nspawn?
      @doc.fetch(:use_sudo_for_nspawn, false)
    end
  end
end

