require 'spec_helper'
require 'spok/workday'

describe 'Spok Calendars' do
  Spok::Workday::CALENDARS.each do |calendar|
    it "has valid dates for #{calendar}" do
      file = File.new(File.join(File.dirname(__FILE__), "../../../lib/spok/config/#{calendar}.yml"))
      last_day = Date.strptime(file.readlines[-1], '- %Y-%m-%d')
      valid_calendar = last_day - 365 > Date.today

      expect(valid_calendar).to eq(true)
    end
  end
end
