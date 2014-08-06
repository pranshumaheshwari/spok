require "period/version"
require "period/date_extensions"

class Period
  DATE_FORMAT = '%Y%m%d'
  attr_reader :start_date, :end_date

  class NullObject
    def to_s
      ''
    end

    def nil?
      true
    end
  end


  def self.parse(period_string)
    return NullObject.new unless period_string

    start_date, end_date = period_string.split('-')

    if start_date && end_date
      Period.new(Date.parse(start_date), Date.parse(end_date))
    else
      NullObject.new
    end
  end

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    validate_period!
  end

  def start_date_as_integer
    as_integer @start_date
  end

  def end_date_as_integer
    as_integer @end_date
  end

  def start_date_as_string
    as_string @start_date
  end

  def end_date_as_string
    as_string @end_date
  end

  def workdays
    (@start_date..@end_date).to_a.delete_if{ |date| date.restday? }
  end

  def to_calendar(calendar = :bovespa)
    Period.new(@start_date.last_workday(calendar), @end_date.last_workday(calendar))
  end

  def to_a
    (@start_date..@end_date).to_a
  end

  def to_s
    "#{start_date_as_string}-#{end_date_as_string}"
  end

  def one_day_period?
    @start_date == @end_date
  end

  def days_count
    (@end_date - @start_date).to_i
  end

  def to_years
    ((@end_date - @start_date).to_f / 365).to_f.round(1)
  end

  def ==(other_period)
    other_period.class == self.class &&
    other_period.start_date == @start_date &&
    other_period.end_date == @end_date
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
