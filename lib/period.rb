require "period/version"
require 'period/workday'

# Public: Class responsible for dealing with periods of Dates, considering
# workdays and restdays.
class Period
  # Internal: String specifying format for dates in the period.
  DATE_FORMAT = '%Y%m%d'
  attr_reader :start_date, :end_date

  # Public: Parses a string into a Period.
  #
  # period_string - String containing the period start and end date separated
  #                 by a dash.
  #
  # Examples
  #
  #   Period.parse('20120101-20120103')
  #   # => #<Period:0x00007f951e8a2ea0 ...>
  #
  #   Period.parse('invalid string')
  #   # => nil
  #
  # Returns a Period or nil when the string does not contain two valid dates.
  def self.parse(period_string)
    return nil unless period_string

    start_date, end_date = period_string.split('-')

    if start_date && end_date
      Period.new(::Date.parse(start_date), ::Date.parse(end_date))
    else
      nil
    end
  end

  # Public: Initialize a Period.
  #
  # start_date - Initial Date for the Period.
  # end_date - Final Date for Period.
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    validate_period!
  end

  # Public: Returns the Period start date as an Integer.
  #
  # Examples
  #
  #   period.start_date_as_integer
  #   # => 20120101
  def start_date_as_integer
    as_integer @start_date
  end

  # Public: Returns the Period end date as an Integer.
  #
  # Examples
  #
  #   period.end_date_as_integer
  #   # => 20120103
  def end_date_as_integer
    as_integer @end_date
  end

  # Public: Returns the Period start date as a String.
  #
  # Examples
  #
  #   period.start_date_as_string
  #   # => "20120101"
  def start_date_as_string
    as_string @start_date
  end

  # Public: Returns the Period end date as a String.
  #
  # Examples
  #
  #   period.end_date_as_string
  #   # => "20120103"
  def end_date_as_string
    as_string @end_date
  end

  # Public: Returns an array containing all workdays on Period.
  #
  # calendar - Symbol informing in which calendar to check for workdays
  #            (default: :brasil).
  #
  # Examples
  #
  #   period.workdays
  #   # => [Mon, 02 Jan 2012, Tue, 03 Jan 2012]
  def workdays(calendar = :brasil)
    (@start_date..@end_date).to_a.delete_if{ |date| Workday.restday?(date, calendar: calendar) }
  end

  # Public: Returns a Period containing the same dates in a different calendar.
  #
  # calendar - Symbol informing calendar for new Period (default: :bovespa).
  #
  # Examples
  #
  #   period.to_calendar(:bovespa)
  #   # => #<Period:0x00007fbf122dba08 ...>
  def to_calendar(calendar = :bovespa)
    Period.new(
      Workday.last_workday(@start_date, calendar: calendar),
      Workday.last_workday(@end_date, calendar: calendar)
    )
  end

  # Public: Returns an array containing all Dates on Period.
  #
  # Examples
  #
  #   period.to_a
  #   # => [Sun, 01 Jan 2012, Mon, 02 Jan 2012, Tue, 03 Jan 2012]
  def to_a
    (@start_date..@end_date).to_a
  end

  # Public: Returns a String containing the Period start and end date separated
  # by a dash.
  #
  # Examples
  #
  #   period.to_s
  #   # => "20120101-20120103"
  def to_s
    "#{start_date_as_string}-#{end_date_as_string}"
  end

  # Public: Informs whether the Period has just one day or not.
  #
  # Examples
  #
  #   period.one_day_period?
  #   # => false
  #
  # Returns a boolean.
  def one_day_period?
    @start_date == @end_date
  end

  # Public: Returns an Integer with the number of days in the Period.
  #
  # Examples
  #
  #   period.days_count
  #   # => 2
  def days_count
    (@end_date - @start_date).to_i
  end

  # Public: Returns a Float with the number of years in the Period.
  #
  # Examples
  #
  #   period.years_count
  #   # => 1.6
  def years_count
    ((@end_date - @start_date).to_f / 365).to_f.round(1)
  end

  # Public: Compares the Period with other Period. Two periods are considered
  # equal when they are both instances of Period, and have the same start and
  # end dates.
  #
  # other_period - Period to be checked against.
  #
  # Examples
  #
  #   period == other_period
  #   # => false
  #
  # Returns a boolean.
  def ==(other_period)
    other_period.class == self.class &&
    other_period.start_date == @start_date &&
    other_period.end_date == @end_date
  end

  # Public: Returns a range containing the Dates in the Period.
  #
  # Examples
  #
  #   period.to_range
  #   # => Sun, 01 Jan 2012..Tue, 03 Jan 2012
  def to_range
    (@start_date..@end_date)
  end

  private

  def as_string(date)
    date.strftime(DATE_FORMAT)
  end

  def as_integer(date)
    date.strftime(DATE_FORMAT).to_i
  end

  def validate_period!
    raise ArgumentError.new("Start date must be present.") unless @start_date
    raise ArgumentError.new("End date must be present.") unless @end_date
    if @start_date > @end_date
      raise ArgumentError.new("End date (#{@end_date}) must be greater or equal to start date (#{@start_date})")
    end
  end
end
