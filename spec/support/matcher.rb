# frozen_string_literal: true

RSpec::Matchers.define :match_js_results do |expected_js_results|
  match do |actual_ruby_results|
    actual_ruby_results = reduce(actual_ruby_results.map(&:to_hash))
    expected_js_results = reduce(expected_js_results)

    @missing = []
    @extra = []
    expected_js_results.each do |js_result|
      @missing << js_result unless actual_ruby_results.include?(js_result)
    end
    actual_ruby_results.each do |ruby_result|
      @extra << ruby_result unless expected_js_results.include?(ruby_result)
    end
    @missing.empty? && @extra.empty?
  end

  failure_message do |_actual|
    "Matches missing from ruby results:\n#{@missing.inspect}\nMatches unique to ruby results:\n#{@extra.inspect}"
  end

  def reduce(results)
    result = []
    results.each do |hash|
      new_hash = {}
      (hash.keys - ['sub', 'sub_display']).sort.each do |key|
        new_hash[key] = hash[key]
      end
      result << new_hash
    end
    result
  end
end
