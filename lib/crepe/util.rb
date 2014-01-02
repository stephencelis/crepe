require 'rack/mime'

module Crepe
  # A collection of helper methods Crepe uses internally.
  module Util

    module_function

    # Recursively dups a hash or array of hashes, leaving others unduped
    #
    # @return [Object]
    def hash_dup value
      case value
        when Hash
          value.each_with_object value.dup do |(k, v), h|
            h[hash_dup k] = hash_dup v
          end
        when Array then value.map { |v| hash_dup v }
        else            value
      end
    end

    # Recursively calls Util.hash_dup and Util.deep_merge! on hashes and their
    # values. This allows a deeply nested hash to be merged with another,
    # without non-Hash or Array values getting duped in the process.
    #
    # @return [Object]
    # @see hash_dup
    # @see deep_merge!
    def deep_merge hash, other_hash
      deep_merge! hash_dup(hash), other_hash
    end

    # Recursively merge a Hash into another hash.
    #
    # @return [Object]
    # @see deep_merge
    def deep_merge! hash, other_hash
      other_hash.each do |key, value|
        if hash[key].is_a?(Hash) && value.is_a?(Hash)
          hash[key] = deep_merge hash[key], value
        else
          hash[key] = value
        end
      end

      hash
    end

    # Recursively freezes all keys and values.
    #
    # @return [Object]
    def deep_freeze value
      case value
        when Hash   then value.freeze.each_value { |v| deep_freeze v }
        when Array  then value.freeze.each { |v| deep_freeze v }
        when String then value.freeze
      end
      value
    end

    def normalize_path path
      normalize_path! path.dup
    end

    def normalize_path! path
      path.squeeze! '/'
      path.chomp! '/'
      path.prepend '/' unless path.start_with? '/'
      path
    end

    def media_types formats
      formats.map(&method(:media_type))
    end

    def media_type format
      Rack::Mime.mime_type ".#{format}", format
    end

  end
end
