require 'spec_helper'
require 'period/workday'
require "period/date_extensions"
require "period/array_extensions"


describe Workday do
  describe '#workday?' do
    context 'monday' do
      it 'is a workday' do
        expect(Date.new(2012, 8, 6)).to be_workday
      end
    end

    context 'saturday' do
      it 'is not a workday' do
        expect(Date.new(2012, 8, 4)).not_to be_workday
      end
    end

    context 'sunday' do
      it 'is not a workday' do
        expect(Date.new(2012, 8, 5)).not_to be_workday
      end
    end

    context 'holidays using brasil calendar' do
      it 'is not a workday' do
        ['2012-06-07', '2012-09-07', '2012-10-12',
         '2012-11-02', '2012-11-15', '2012-12-25'].each do |holiday|
          expect(Date.parse(holiday)).not_to be_workday
        end
      end
    end

    context 'holidays using bovespa calendar' do
      it 'is not a workday' do
        ['2012-07-09', '2012-11-20', '2012-12-24'].each do |holiday|
          expect(Date.parse(holiday).workday?(:bovespa)).to eq(false)
        end
      end
    end

  end

  describe '#restday?' do
    context 'Using Date objects' do
      context 'monday' do
        it 'is not a restday' do
          expect(Date.new(2012, 8, 6)).not_to be_restday
        end
      end

      context 'saturday' do
        it 'is a restday' do
          expect(Date.new(2012, 8, 4)).to be_restday
        end
      end

      context 'sunday' do
        it 'is a restday' do
          expect(Date.new(2012, 8, 5)).to be_restday
        end
      end

      context 'holiday' do
        [
          Date.new(2012, 6, 07),
          Date.new(2012, 9, 07),
          Date.new(2012, 10, 12),
          Date.new(2012, 11, 02),
          Date.new(2012, 11, 15),
          Date.new(2012, 12, 25)
        ].each do |holiday|
          it 'is a restday' do
            expect(holiday).to be_restday
          end
        end
      end
    end

    context 'using DateTime objects' do
      context 'monday' do
        it 'is not a restday' do
          expect(DateTime.new(2012, 8, 6, 12)).not_to be_restday
        end
      end

      context 'saturday' do
        it 'is a restday' do
          expect(DateTime.new(2012, 8, 4, 12)).to be_restday
        end
      end

      context 'sunday' do
        it 'is a restday' do
          expect(DateTime.new(2012, 8, 5, 13)).to be_restday
        end
      end

      context 'holiday' do
        [
          DateTime.new(2017, 01, 01, 00),
          DateTime.new(2017, 10, 12, 01),
          DateTime.new(2017, 11, 02, 02),
          DateTime.new(2017, 11, 15, 03),
          DateTime.new(2017, 12, 25, 04)
        ].each do |holiday|
          it 'is a restday' do
            expect(holiday).to be_restday
          end
        end
      end
    end
  end

  describe '#last_workday' do
    context 'when date is 2012-10-25 (Thursday)' do
      it 'returns the same date' do
        expect(Date.new(2012, 10, 25).last_workday).to eq(Date.new(2012, 10, 25))
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-19 (Friday)' do
        expect(Date.new(2012, 10, 21).last_workday).to eq(Date.new(2012, 10, 19))
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-19 (Friday)' do
        expect(Date.new(2012, 10, 20).last_workday).to eq(Date.new(2012, 10, 19))
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2013-01-01 (bovespa holiday)' do
        it 'returns 2012-12-30,  because 2012-12-31 is also a bovespa holiday and 2012-01-30|29 is a weekend' do
          expect(Date.new(2013, 1, 1).last_workday(:bovespa)).to eq(Date.new(2012, 12, 28))
        end
      end
    end
  end

  describe '#next_workday' do
    context 'when date is 2012-10-26 (Friday)' do
      it 'returns the same date' do
        expect(Date.new(2012, 10, 26).next_workday).to eq(Date.new(2012, 10, 26))
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-22 (Monday)' do
        expect(Date.new(2012, 10, 21).next_workday).to eq(Date.new(2012, 10, 22))
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-22 (Monday)' do
        expect(Date.new(2012, 10, 20).next_workday).to eq(Date.new(2012, 10, 22))
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2012-12-30 (sunday)' do
        it 'returns 2013-01-02, because 2012, 12, 31 and 2013-01-01 are bovespa holidays' do
          expect(Date.new(2012, 12, 30).next_workday(:bovespa)).to eq(Date.new(2013, 1, 2))
        end
      end
    end
  end
end

describe Workdays do
  describe '#as_string' do
    it 'formats each workday as string' do
      expect([Date.new(2013, 4, 4), Date.new(2013, 4, 5)].as_string).to eq(['20130404', '20130405'])
    end

    it 'returns empty if the workdays are empty' do
      expect([].as_string).to eq([])
    end
  end
end
