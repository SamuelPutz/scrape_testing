require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'dotenv/load'
require 'byebug'

def get_and_insert_data(client)
  document = Nokogiri::HTML(URI.open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html")&.body)
  cells = []
  doc = document.at('tbody')
  byebug
  # doc.search('tr').each do |row|
  #   cells << row.search('th, td').map { |cell| cell.text.strip }

  #   client.query("insert into covid_test_gabriel(week, total_spec_tested_including_age_unkown, total_percent_pos_including_age_unkown, 
  #     0_to_4_yrs_spec_tested, 0_to_4_yrs_percent_pos, 5_to_17_yrs_spec_tested, 5_to_17_yrs_percent_pos, 18_to_49_yrs_spec_tested, 18_to_49_yrs_percent_pos, 
  #     50_to_64_spec_tested, 50_to_64_percent_pos, 65_plus_yrs_spec_tested, 65_plus_yrs_percent_pos)
  #   values ();")
  # end
end

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

get_and_insert_data(client)

client.close