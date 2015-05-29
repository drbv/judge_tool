module Calculator
  class MistakeAverage

    def initialize(mistakes_set, decider_mistakes = nil)
      @number_judges = mistakes_set.size
      @mistakes_set = mistakes_set.map { |mistakes| mistakes.split(',').group_by { |mistake| mistake[0].to_sym } }
      @decider_mistakes = decider_mistakes.split(',').group_by { |mistake| mistake[0].to_sym } if decider_mistakes
    end

    def calculate
      %i(T S U V).map do |mistake_type|
        mean_values choose_only_mistakes_for(mistake_type), @decider_mistakes && (@decider_mistakes[mistake_type] || [])
      end.select {|e| e!=''}.join(',')
    end

    private

    def mean_values(mistakes_set, decider_mistakes)
      number_of_mistakes(mistakes_set, decider_mistakes).times.map do
        mean_value mistakes_set.map(&:shift), decider_mistakes && decider_mistakes.shift
      end.join(',')
    end

    def mean_value(mistakes, decider_mistake)
      grouped = mistakes.compact.group_by { |e| e }.values
      max_occurrence = grouped.map(&:size).max
      majorities = grouped.select { |e| e.size == max_occurrence }
      majorities.map!(&:first)
      if majorities.size == 1
        majorities.first
      elsif in_dubio_pro_reo?(majorities, decider_mistake)
        "#{majorities.first[0]}#{majorities.map {|mistake| mistake[1..-1].to_i}.min}"
      else
        decider_mistake
      end
    end

    def in_dubio_pro_reo?(majorities, decider_mistake)
      decider_mistake.nil? || !majorities.include?(decider_mistake)
    end

    def number_of_mistakes(mistakes_set, decider_mistakes)
      @number_of_mistakes = 0
      (1..mistakes_set.map(&:size).max).each do |k|
        mistakes_set.map(&:size).select { |n| n >= k }.size.tap do |size|
          if size > (@number_judges.to_f / 2) || (size == (@number_judges.to_f / 2) && decider_mistakes && decider_mistakes.size >= k)
            @number_of_mistakes = k
          else
            return @number_of_mistakes
          end
        end
      end
      @number_of_mistakes
    end

    def choose_only_mistakes_for(mistake_type)
      @mistakes_set.map do |e|
        if !e[mistake_type].nil?
          e[mistake_type].sort_by {|e| e[1..2].to_i}.reverse
        else
          []
        end
      end
    end

  end
end