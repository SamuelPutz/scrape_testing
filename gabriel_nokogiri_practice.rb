require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'dotenv/load'
require 'byebug'

def get_and_insert_data(client)
  document = Nokogiri::HTML(URI.open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html"))
  rows = []
  doc = document.at('tbody')
  doc.search('tr').each do |row|
    row = row.text.split("\n")[1..-1] # array of all the cells in the first row
    row.map{|el| el.to_s.gsub(',','')}
    rows << {"week"=>row[0],"total_spec_tested_including_age_unkown"=>row[1],"total_percent_pos_including_age_unkown"=>row[2],
      "0_to_4_yrs_spec_tested"=>row[3],"0_to_4_yrs_percent_pos"=>row[4],"5_to_17_yrs_spec_tested"=>row[5]
      ,"5_to_17_yrs_percent_pos"=>row[6],"18_to_49_yrs_spec_tested"=>row[7],"18_to_49_yrs_percent_pos"=>row[8]
      ,"50_to_64_spec_tested"=>row[9],"50_to_64_percent_pos"=>row[10],"65_plus_yrs_spec_tested"=>row[11],"65_plus_yrs_percent_pos"=>row[12]}
  end

  rows.each_slice(20000) do |rows_|
    insert = "INSERT IGNORE INTO covid_test_gabriel(week, total_spec_tested_including_age_unkown, total_percent_pos_including_age_unkown, 
        0_to_4_yrs_spec_tested, 0_to_4_yrs_percent_pos, 5_to_17_yrs_spec_tested, 5_to_17_yrs_percent_pos, 18_to_49_yrs_spec_tested, 18_to_49_yrs_percent_pos, 
        50_to_64_spec_tested, 50_to_64_percent_pos, 65_plus_yrs_spec_tested, 65_plus_yrs_percent_pos)
        VALUES "
    rows_.each do |row|
      insert += "(#{row['week']},#{row['total_spec_tested_including_age_unkown']},#{row['total_percent_pos_including_age_unkown']},
      #{row['0_to_4_yrs_spec_tested']},#{row['0_to_4_yrs_percent_pos']},#{row['5_to_17_yrs_spec_tested']},#{row['5_to_17_yrs_percent_pos']},
      #{row['18_to_49_yrs_spec_tested']},#{row['18_to_49_yrs_percent_pos']},#{row['50_to_64_spec_tested']},#{row['50_to_64_percent_pos']},
      #{row['65_plus_yrs_spec_tested']},#{row['65_plus_yrs_percent_pos']}),"
    end
    client.query(insert.chop!)
  end

end

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

get_and_insert_data(client)

client.close