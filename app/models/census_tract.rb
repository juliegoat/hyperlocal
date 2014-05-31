require 'csv'
require 'open-uri'
class CensusTract < ActiveRecord::Base

  validate :fips, presence: true
  serialize :boundary

  def self.import_from_csv(csv_path)
    csv     = ::CSV.open(csv_path)
    headers = csv.gets
    data    = csv.read
    
    data.each do |row|
      CensusTract.create(fips: row[headers.index('CensusTract')], state: row[headers.index('State')], county: row[headers.index('County')])
    end

  end

  def populate_boundary
    self.boundary = geocode_tract
    save
  end

  def geojson_polygon
    {
      type: 'polygon',
      coordinates: boundary
    }.to_json
  end

  private

  def geocode_tract
    response = open geocoder_url
    response.lines.first.scan(/new PLatLng\((-?[0-9]{2}\.-?[0-9]{4}),(-?[0-9]{2}\.-?[0-9]{4})\)/)
  end

  def geocoder_url
    "http://www.policymap.com/servlets/boundary/get/?t=fips&i=#{fips}&di=51,24&ord=1&ars=1&c=jQuery110203884256037417799_1401567075913&_=1401567075939"
  end

end