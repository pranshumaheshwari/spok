require 'spec_helper'
require 'period'

describe Period do
  let(:date1) { Date.new(2012,01,01) } # Sunday
  let(:date2) { Date.new(2012,01,02) } # Monday
  let(:date3) { Date.new(2012,01,03) } # Tuesday

  subject(:period) { described_class.new(date1, date3) }

  describe '.parse' do
    it { described_class.parse('20120101-20120103').should == period }

    context 'when the input string is wrong' do
      it { described_class.parse('20120101').should be_kind_of(Period::NullObject) }
      it { described_class.parse(nil).should be_kind_of(Period::NullObject) }
      it { described_class.parse('').should be_kind_of(Period::NullObject) }
    end
  end

  describe '#date_as_integer' do
    it 'represents the start date as integer' do
      subject.start_date_as_integer.should == 20120101
    end

    it 'represents the end date as integer' do
      subject.end_date_as_integer.should == 20120103
    end
  end

  describe '#date_as_string' do
    it 'represents the start date as string' do
      subject.start_date_as_string.should == '20120101'
    end

    it 'represents the end date as string' do
      subject.end_date_as_string.should == '20120103'
    end
  end

  describe '#validate_period!' do
    it 'does not raise error when start date is before or equals to the end date' do
      expect { subject }.not_to raise_error
      expect { described_class.new(date1, date1) }.not_to raise_error
    end

    it 'raises exception when the start date is nil' do
      expect { described_class.new(nil, date1) }.to raise_error(ArgumentError)
    end

    it 'raises exception when the end date is nil' do
      expect { described_class.new(date3, nil) }.to raise_error(ArgumentError)
    end

    it 'raises exception when the start date is greater than the end date' do
      expect { described_class.new(date3, date1) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    subject(:to_s) { period.to_s }
    it { should == '20120101-20120103' }
  end

  describe '#workdays' do
    it 'returns only the workdays' do
      subject.workdays.should == [date2, date3]
    end
  end

  describe '#to_calendar' do
    context 'when bovespa is the calendar' do
      subject { described_class.new(date1, date3).to_calendar(:bovespa) }
      context 'and start date on a bovespa holiday' do
        let(:start_date) { Date.new(2013, 7, 8) }
        let(:date1)      { Date.new(2013, 7, 9) } # bovespa holiday
        let(:date3)      { Date.new(2013, 7, 11) }
        it 'returns the last bovespa workday as the start date' do
          subject.start_date.should == start_date
        end
      end

      context 'and end date on a bovespa holiday' do
        let(:date1)    { Date.new(2013, 7, 7) }
        let(:date3)    { Date.new(2013, 7, 9) } # bovespa holiday
        let(:end_date) { Date.new(2013, 7, 8) }
        it 'returns the last bovespa workday as the end date' do
          subject.end_date.should == end_date
        end
      end

      context 'and start and end date on a bovespa holiday' do
        let(:date1)    { Date.new(2012, 12, 31) } #bovespa holiday
        let(:date3)    { Date.new(2013, 1, 1) } # bovespa holiday
        it 'start and end date are going to be the same' do
          subject.start_date.should == subject.end_date
        end
      end
    end

    context 'when brasil is the calendar' do
      subject { described_class.new(date1, date3).to_calendar(:brasil) }

      context 'and the start date is holiday' do
        let(:start_date) { Date.new(2013, 9, 6) }
        let(:date1)      { Date.new(2013, 9, 7) } # brasil holiday
        let(:date3)      { Date.new(2013, 9, 10) }
        it 'returns the last workday as the start date' do
          subject.start_date.should == start_date
        end
      end

      context 'end date on a bovespa holiday' do
        let(:date1)    { Date.new(2013, 9, 5) }
        let(:date3)    { Date.new(2013, 9, 7) } # brasil holiday
        let(:end_date) { Date.new(2013, 9, 6) }
        it 'returns the last bovespa workday as the end date' do
          subject.end_date.should == end_date
        end
      end
    end
  end

  describe '#one_day_period?' do
    context 'when the start and end date are the same' do
      let(:date3)    { date1 }
      it { subject.should be_one_day_period }
    end

    context 'when the start and end date are different' do
      it { subject.should_not be_one_day_period }
    end
  end

  describe '#days_count' do
    subject { described_class.new(start_date, end_date).days_count }

    let(:start_date) { date1 }
    let(:end_date)   { date3 }
    it { should == 2 }

    context 'when start date is equals to the end date' do
      let(:start_date) { date1 }
      let(:end_date)   { date1 }

      it { should == 0 }
    end
  end

  describe '#years_difference' do
    subject(:years_difference) { described_class.new(start_date, end_date).years_difference }
    let(:start_date) { Date.new(2013, 1, 1) }

    context 'when integer result' do
      let(:end_date) { Date.new(2014, 1, 1) }
      it { should == 1 }
    end

    context 'when fraction result' do
      let(:end_date) { Date.new(2014, 7, 1) }
      it { should == 1.5 }
    end

    context 'when fraction result' do
      let(:end_date) { Date.new(2014, 9, 1) }
      it { should == 1.7 }
    end
  end

  describe '#==' do
    let(:period) { Period.new(date1, date3) }

    context 'when periods are equal' do
      let(:other_period) { Period.new(date1, date3) }

      it { (period == other_period).should be_true }
    end

    context 'when periods are not equal' do
      let(:other_period) { Period.new(date1, date2) }

      it { (period == other_period).should be_false }
    end

    context 'when the comparison does respond to start date' do
      let(:other_period) { double(:other_period, :end_date => double(:end_date)) }
      it { (period == other_period).should be_false }
    end

    context 'when the comparison does respond to end date' do
      let(:other_period) { double(:other_period, :start_date => date1) }
      it { (period == other_period).should be_false }
    end
  end
end
