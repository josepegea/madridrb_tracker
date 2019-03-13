require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'termux_ruby_api'
require "sinatra/activerecord"
require 'otr-activerecord'

OTR::ActiveRecord.configure_from_file! "config/database.yml"

require_relative 'models/location'
require_relative 'models/sensor_status'

get '/' do
  @steps = SensorStatus.where("moment >= ?", Date.yesterday).sum(:steps)
  @steps_summary = SensorStatus
                     .select("date_trunc('day', moment) as moment, SUM(steps) as steps")
                     .where("moment >= ?", 1.week.ago.beginning_of_day)
                     .group("date_trunc('day', moment)")
                     .order("moment desc")
  haml :index
end

get "/day_steps" do
  @day = Date.parse(params[:day])
  if @day
    @steps_summary = SensorStatus
                       .select("date_trunc('hour', moment) as moment, SUM(steps) as steps")
                       .where("moment >= ? and moment < ?", @day, @day + 1)
                       .group("date_trunc('hour', moment)")
                       .order("date_trunc('hour', moment) asc")
    steps_hash = Hash[@steps_summary.map { |step| [step[:moment].hour, step[:steps]] }]
    @hours = (0..23).to_a.map { |h| steps_hash[h] || 0 }
    haml :day_steps, layout: :layout_graph
  else
    redirect_to("/")
  end
end

get "/map" do
  @day = get_day
  if @day
    haml :map, layout: :layout_map
  else
    redirect_to("/")
  end
end

get "/map.json" do
  @day = get_day
  locations = Location.where("moment >= ? and moment < ?", @day, @day + 1)
  sql = <<-SQL
    select position, steps from (
    select position, steps, sum(steps) over (partition by date_trunc('minute', moment)) as sum_steps
    from sensor_statuses
    where moment >= ? and moment < ?
    ) ss
    where sum_steps > 60
  SQL
  steps = SensorStatus.find_by_sql([sql, @day, @day + 1])
  json_data = {
    path: {
      type: "LineString",
      coordinates: locations.map { |l| l.position.to_a }
    },
    steps: {
      type: "FeatureCollection",
      features: steps.map do |step|
        {
          type: "Feature",
          geometry: {
            type: "Point",
            coordinates: step.position.to_a
          }
        }
      end
    }
  }
  json_data.to_json
end

def get_day
  params[:day].present? ? Date.parse(params[:day]) : Date.today
end

def link_to(label, path)
  "<a href=\"#{url(path)}\">#{label}</a>"
end
