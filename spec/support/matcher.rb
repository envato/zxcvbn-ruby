RSpec::Matchers.define :match_js_results do |expected_js_results|
  match do |actual_ruby_results|
    ruby_results = convert_matches_to_hash(actual_ruby_results)
    ruby_results = sort(ruby_results)
    expected_js_results = sort(expected_js_results)
    (ruby_results + expected_js_results).each do |result|
      ['sub_display'].each do |key|
        result.delete(key)
      end
    end

    ruby_results == expected_js_results
  end

  def convert_matches_to_hash(results)
    results.map do |match|
      hash = match.instance_variable_get('@table')
      hash.keys.each do |key|
        hash[key.to_s] = hash.delete(key)
      end
      hash
    end
  end

  def sort(results)
    results.sort_by do |hash|
      [hash['pattern'], hash['i'], hash['j'], hash['matched_word'], hash['dictionary_name']]
    end
  end
end