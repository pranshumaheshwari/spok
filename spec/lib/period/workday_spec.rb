require 'spec_helper'
require 'period/workday'
require "period/date_extensions"
require "period/array_extensions"


describe Workday do
  describe '#workday?' do
    context 'monday' do
      it 'is a workday' do
        Date.new(2012,  8,  6).should be_workday
      end
    end

    context 'saturday' do
      it 'is not a workday' do
        Date.new(2012,  8,  4).should_not be_workday
      end
    end

    context 'sunday' do
      it 'is not a workday' do
        Date.new(2012,  8,  5).should_not be_workday
      end
    end

    context 'holidays using brasil calendar' do
      it 'is not a workday' do
        ['2012-06-07',  '2012-09-07',  '2012-10-12',
         '2012-11-02',  '2012-11-15',  '2012-12-25'].each do |holiday|
          Date.parse(holiday).should_not be_workday
        end
      end
    end

    context 'holidays using bovespa calendar' do
      it 'is not a workday' do
        ['2012-07-09',  '2012-11-20',  '2012-12-24'].each do |holiday|
          Date.parse(holiday).workday?(:bovespa).should be_false
        end
      end
    end

  end

  describe '#restday?' do
    context 'monday' do
      it 'is not a restday' do
        Date.new(2012,  8,  6).should_not be_restday
      end
    end

    context 'saturday' do
      it 'is a restday' do
        Date.new(2012,  8,  4).should be_restday
      end
    end

    context 'sunday' do
      it 'is a restday' do
        Date.new(2012,  8,  5).should be_restday
      end
    end

    context 'holiday' do
      it 'is a restday' do
        ['2012-06-07',  '2012-09-07',  '2012-10-12',
         '2012-11-02',  '2012-11-15',  '2012-12-25'].each do |holiday|
          Date.parse(holiday).should be_restday
        end
      end
    end
  end

  describe '#last_workday' do
    context 'when date is 2012-10-25 (Thursday)' do
      it 'returns the same date' do
        Date.new(2012, 10, 25).last_workday.should == Date.new(2012, 10, 25)
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-19 (Friday)' do
        Date.new(2012, 10, 21).last_workday.should == Date.new(2012, 10, 19)
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-19 (Friday)' do
        Date.new(2012, 10, 20).last_workday.should == Date.new(2012, 10, 19)
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2013-01-01 (bovespa holiday)' do
        it 'returns 2012-12-30,  because 2012-12-31 is also a bovespa holiday and 2012-01-30|29 is a weekend' do
          Date.new(2013, 1, 1).last_workday(:bovespa).should == Date.new(2012, 12, 28)
        end
      end
    end
  end

  describe '#next_workday' do
    context 'when date is 2012-10-26 (Friday)' do
      it 'returns the same date' do
        Date.new(2012, 10, 26).next_workday.should == Date.new(2012, 10, 26)
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-22 (Monday)' do
        Date.new(2012, 10, 21).next_workday.should == Date.new(2012, 10, 22)
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-22 (Monday)' do
        Date.new(2012, 10, 20).next_workday.should == Date.new(2012, 10, 22)
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2012-12-30 (sunday)' do
        it 'returns 2013-01-02, because 2012, 12, 31 and 2013-01-01 are bovespa holidays' do
          Date.new(2012, 12, 30).next_workday(:bovespa).should == Date.new(2013, 1, 2)
        end
      end
    end
  end
end

describe Workdays do
  describe '#as_string' do
    it 'formats each workday as string' do
      [Date.new(2013, 4, 4), Date.new(2013, 4, 5)].as_string.should == ['20130404', '20130405']
    end

    it 'returns empty if the workdays are empty' do
      [].as_string.should == []
    end
  end
end
