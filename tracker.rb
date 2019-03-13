require 'termux_ruby_api'
require 'active_record'
require 'otr-activerecord'

OTR::ActiveRecord.configure_from_file! "config/database.yml"

require_relative 'models/location'
require_relative 'models/sensor_status'

class Tracker

  attr_accessor :api
  
  def initialize
    @api = TermuxRubyApi::Base.new
  end

  def track_steps
    last_step_count = nil
    puts "Start tracking steps"
    api.sensor.capture(sensors: ["Step Counter"]) do |res|
      current_step_count = res && res.dig("Step Counter", "values").first
      if last_step_count
        steps = current_step_count - last_step_count
        steps = current_step_count if steps < 0
        puts "Steps #{steps}"
        SensorStatus.create(steps: steps, moment: Time.current) if steps > 0
      end
      last_step_count = current_step_count
    end
  end

  def track_location
    puts "Start tracking location"
    while true do
      res = api.location.gps
      puts "Location #{res}"
      Location.create(res.slice(:altitude, :accuracy, :speed, :bearing)
                        .merge(position: [res[:longitude], res[:latitude]],
                               moment: Time.current))
      sleep 5
    end
  end

  def track_all
    t_loc = Thread.new { track_location }
    t_steps = Thread.new { track_steps }
    t_loc.join
    t_steps.join
  end
end

Tracker.new.track_all
