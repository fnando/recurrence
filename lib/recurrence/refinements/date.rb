# frozen_string_literal: true

class Recurrence_
  module Refinements
    refine Date.singleton_class do
      def tomorrow
        today.next_day
      end

      def yesterday
        today.prev_day
      end
    end
  end
end
