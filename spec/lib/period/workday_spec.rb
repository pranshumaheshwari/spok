require 'spec_helper'
require 'period/workday'

describe Workday do
  describe '#workday?' do
    context 'monday' do
      it 'is a workday' do
        expect(Workday.workday?(Date.new(2012, 8, 6))).to eq(true)
      end
    end

    context 'saturday' do
      it 'is not a workday' do
        expect(Workday.workday?(Date.new(2012, 8, 4))).to eq(false)
      end
    end

    context 'sunday' do
      it 'is not a workday' do
        expect(Workday.workday?(Date.new(2012, 8, 5))).to eq(false)
      end
    end

    context 'holidays using brasil calendar' do
      it 'is not a workday' do
        ['2012-06-07', '2012-09-07', '2012-10-12',
         '2012-11-02', '2012-11-15', '2012-12-25'].each do |holiday|
          expect(Workday.workday?(Date.parse(holiday))).to eq(false)
        end
      end
    end

    context 'holidays using bovespa calendar' do
      it 'is not a workday' do
        ['2012-07-09', '2012-11-20', '2012-12-24'].each do |holiday|
          expect(Workday.workday?(Date.parse(holiday), calendar: :bovespa)).to eq(false)
        end
      end
    end

  end

  describe '#restday?' do
    context 'Using Date objects' do
      context 'monday' do
        it 'is not a restday' do
          expect(Workday.restday?(Date.new(2012, 8, 6))).to eq(false)
        end
      end

      context 'saturday' do
        it 'is a restday' do
          expect(Workday.restday?(Date.new(2012, 8, 4))).to eq(true)
        end
      end

      context 'sunday' do
        it 'is a restday' do
          expect(Workday.restday?(Date.new(2012, 8, 5))).to eq(true)
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
            expect(Workday.restday?(holiday)).to eq(true)
          end
        end
      end
    end

    context 'using DateTime objects' do
      context 'monday' do
        it 'is not a restday' do
          expect(Workday.restday?(DateTime.new(2012, 8, 6, 12))).to eq(false)
        end
      end

      context 'saturday' do
        it 'is a restday' do
          expect(Workday.restday?(DateTime.new(2012, 8, 4, 12))).to eq(true)
        end
      end

      context 'sunday' do
        it 'is a restday' do
          expect(Workday.restday?(DateTime.new(2012, 8, 5, 13))).to eq(true)
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
            expect(Workday.restday?(holiday)).to eq(true)
          end
        end
      end
    end
  end

  describe '#last_workday' do
    context 'when date is 2012-10-25 (Thursday)' do
      it 'returns the same date' do
        expect(Workday.last_workday(Date.new(2012, 10, 25))).to eq(Date.new(2012, 10, 25))
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-19 (Friday)' do
        expect(Workday.last_workday(Date.new(2012, 10, 21))).to eq(Date.new(2012, 10, 19))
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-19 (Friday)' do
        expect(Workday.last_workday(Date.new(2012, 10, 20))).to eq(Date.new(2012, 10, 19))
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2013-01-01 (bovespa holiday)' do
        it 'returns 2012-12-30,  because 2012-12-31 is also a bovespa holiday and 2012-01-30|29 is a weekend' do
          expect(Workday.last_workday(Date.new(2013, 1, 1), calendar: :bovespa)).to eq(Date.new(2012, 12, 28))
        end
      end
    end
  end

  describe '#next_workday' do
    context 'when date is 2012-10-26 (Friday)' do
      it 'returns the same date' do
        expect(Workday.next_workday(Date.new(2012, 10, 26))).to eq(Date.new(2012, 10, 26))
      end
    end

    context 'when date is 2012-10-21 (Sunday)' do
      it 'returns 2012-10-22 (Monday)' do
        expect(Workday.next_workday(Date.new(2012, 10, 21))).to eq(Date.new(2012, 10, 22))
      end
    end

    context 'when date is 2012-10-20 (Saturday)' do
      it 'returns 2012-10-22 (Monday)' do
        expect(Workday.next_workday(Date.new(2012, 10, 20))).to eq(Date.new(2012, 10, 22))
      end
    end

    context 'when bovespa calendar' do
      context 'when date is 2012-12-30 (sunday)' do
        it 'returns 2013-01-02, because 2012, 12, 31 and 2013-01-01 are bovespa holidays' do
          expect(Workday.next_workday(Date.new(2012, 12, 30), calendar: :bovespa)).to eq(Date.new(2013, 1, 2))
        end
      end
    end
  end
end
