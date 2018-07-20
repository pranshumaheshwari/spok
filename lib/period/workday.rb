require 'active_support'
require 'active_support/core_ext'
require 'set'
require 'yaml'

class Period
  # Public: Various methods useful for checking for restdays and workdays.
  # All methods are module methods and should be called on the Period::Workday
  # module.
  module Workday
    # TODO: add holidays before 2001 for :brasil (use :bovespa to infer?)
    # TODO: remove weekend dates from :brasil

    # Public: Array of available calendars.
    CALENDARS = %i(brasil bovespa)

    # Public: Hash containing all holidays for each available calendar.
    HOLIDAYS = CALENDARS.map do |calendar|
      holidays_file = File.open(File.join(File.dirname(__FILE__), "config/#{calendar}.yml"))
      holidays = YAML.safe_load(holidays_file.read, [Date])
      [calendar, Set.new(holidays[calendar.to_s])]
    end.to_h

    # Public: Checks if a given day is a restday.
    #
    # date     - The Date to be checked.
    # calendar - Symbol informing in which calendar the date will be checked
    #            (default: :brasil).
    #
    # Examples
    #
    #   Period::Workday.restday?(Date.new(2012, 8, 6))
    #   # => false
    #
    # Returns a boolean.
    def self.restday?(date, calendar: :brasil)
      weekday = date.wday

      weekday == 0 || #saturday
      weekday == 6 || #sunday
      HOLIDAYS[calendar].include?(date.to_date)
    end

    # Public: Checks if a given day is a workday.
    #
    # date     - The Date to be checked.
    # calendar - Symbol informing in which calendar the date will be checked
    #            (default: :brasil).
    #
    # Examples
    #
    #   Period::Workday.workday?(Date.new(2012, 8, 6))
    #   # => true
    #
    # Returns a boolean.
    def self.workday?(date, calendar: :brasil)
      !restday?(date, calendar: calendar)
    end


    # Public: Returns the last workday until the informed date.
    # It returns the informed date in case it is a workday.
    #
    # date     - End Date to check for workdays.
    # calendar - Symbol informing in which calendar to check for workdays
    #            (default: :brasil).
    #
    # Examples
    #   Period::Workday.last_workday(Date.new(2012, 10, 21))
    #   # => #<Date: 2012-10-19 ((2456220j,0s,0n),+0s,2299161j)>
    def self.last_workday(date, calendar: :brasil)
      return date if workday?(date, calendar: calendar)

      last_workday((date - 1.day), calendar: calendar)
    end

    # Public: Returns the next workday starting from the informed date.
    # It returns the informed date in case it is a workday.
    #
    # date     - Start Date to check for workdays.
    # calendar - Symbol informing in which calendar to check for workdays
    #            (default: :brasil).
    #
    # Examples
    #   Period::Workday.next_workday(Date.new(2012, 10, 21))
    #   # => #<Date: 2012-10-19 ((2456220j,0s,0n),+0s,2299161j)>
    def self.next_workday(date, calendar: :brasil)
      return date if workday?(date, calendar: calendar)

      next_workday((date + 1.day), calendar: calendar)
    end
  end
end
