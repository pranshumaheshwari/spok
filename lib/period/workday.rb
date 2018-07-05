require 'active_support'
require 'active_support/core_ext'
require 'set'
require 'yaml'

class Period
  module Workday
    # Hash of Arrays containing Dates of holidays
    # Brasil  => 2001 - 2078
    # Bovespa => 1993 - 2022
    # TODO: add holidays before 2001 for :brasil (use :bovespa to infer?)
    # TODO: remove weekend dates from :brasil

    CALENDARS = %i(brasil bovespa)

    HOLIDAYS = CALENDARS.map do |calendar|
      holidays_file = File.open(File.join(File.dirname(__FILE__), "config/#{calendar}.yml"))
      holidays = YAML.safe_load(holidays_file.read, [Date])
      [calendar, Set.new(holidays[calendar.to_s])]
    end.to_h

    def self.restday?(date, calendar: :brasil)
      weekday = date.wday

      weekday == 0 || #saturday
      weekday == 6 || #sunday
      HOLIDAYS[calendar].include?(date.to_date)
    end

    def self.workday?(date, calendar: :brasil)
      !restday?(date, calendar: calendar)
    end

    def self.last_workday(date, calendar: :brasil)
      return date if workday?(date, calendar: calendar)

      last_workday((date - 1.day), calendar: calendar)
    end

    def self.next_workday(date, calendar: :brasil)
      return date if workday?(date, calendar: calendar)

      next_workday((date + 1.day), calendar: calendar)
    end
  end
end
