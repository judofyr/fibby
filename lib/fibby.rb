require 'delegate'
require 'ippon/form_data'
require 'ippon/validate'

module Fibby
  DEFAULT_SCHEMA = Ippon::Validate::Builder.validate { true }

  class Field
    class << self
      attr_writer :schema

      def schema
        @schema ||= defined?(super) ? super : DEFAULT_SCHEMA
      end
    end


    attr_writer :key

    def key
      @key or raise "key has not been defined yet"
    end

    def self.call
      new
    end

    attr_writer :schema

    def schema
      @schema ||= self.class.schema
    end

    attr_reader :result

    def validate
      @result ||= _validate
    end

    def _validate
      schema.validate(value)
    end

    def error?
      @result && @result.error?
    end
  end

  class Text < Field
    attr_reader :value

    def each_pair
      yield key.to_s, value
    end

    def from_params(params)
      @value = params.fetch(key) { "" }
    end

    def from_object(obj)
      @value = obj.to_s
    end
  end

  class TextList < Field
    attr_reader :values

    def each_pair
      values.each do |value|
        yield key.to_s, value
      end
    end

    def from_params(params)
      @values = params.fetch_all(key)
    end

    def from_object(obj)
      @values = obj.map(&:to_s)
    end

    def _validate
      schema.validate(@values)
    end
  end

  class Flag < Field
    attr_reader :value

    def each_pair
      if @value
        yield key.to_s, "1"
      end
    end

    def from_params(params)
      @value = !!params[key]
    end

    def from_object(obj)
      @value = !!obj
    end
  end

  class Form < Field
    attr_reader :children

    def initialize
      @children = {}
    end

    def key=(key)
      super
      @children.each do |name, field|
        field.key = key[name]
      end
    end

    def field(name, instance)
      yield instance if block_given?
      @children[name] = instance
      self
    end

    def [](name)
      @children.fetch(name)
    end

    def each_pair(&blk)
      @children.each do |name, field|
        field.each_pair(&blk)
      end
    end

    def from_params(params)
      @children.each do |name, field|
        field.from_params(params)
      end
    end

    def from_object(obj)
      @children.each do |name, field|
        field.from_object(obj[name])
      end
    end

    def from_hash(h)
      h.each do |name, value|
        self[name].from_object(value)
      end
    end

    def _validate
      result = Ippon::Validate::Result.new({})
      child_results = @children.map { |name, field| [name, field.validate] }
      Ippon::Validate::Form.process_children(result, child_results)
      schema.process(result) if !result.error?
      result
    end
  end

  class DelegateForm < Delegator
    attr_reader :form

    def form
      @__form__ ||= Form.new
    end

    def __getobj__
      form
    end
  end
end
