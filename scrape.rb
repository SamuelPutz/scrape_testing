require 'nokogiri'
require 'httparty'
require 'byebug'


def parse_page
  file_content = HTTParty.get("https://www.nifa.org/news/view-article/NE_4HandFFA_clubs")&.body
  page_parsed = Nokogiri::HTML(file_content)
  article_doc = Nokogiri::HTML(file_content).at('.news_content')
  article_doc.search('h1').children.remove
  article_doc.search('h1').remove
  if article_doc.search('h2').first.nil? == false || article_doc.search('h3').first.nil? == false
    article_doc.search('h2').first.nil? ?  article_doc.search('h3').first.remove : article_doc.search('h2').first.remove
  end
  article = article_doc.children.to_html.strip
  teaser_doc = Nokogiri::HTML(file_content).at('.news_article')
  teaser_doc.search('h1').children.remove
  teaser_doc.search('h1').remove

  if teaser_doc.search('h2').first.nil? == false || teaser_doc.search('h3').first.nil? == false
    teaser = teaser_doc.search('h2').first.nil? ?  teaser_doc.search('h3').first.text.strip : teaser_doc.search('h2').first.text.strip
    teaser_doc = teaser_doc.at('.news_content')
    if teaser.gsub(/[[:space:]]/, '') == '' && teaser_doc.search('p')[0].nil? == false
      teaser = teaser_doc.search('p')[0].text.strip
      if teaser.gsub(/[[:space:]]/, '') == '' && teaser_doc.search('p')[1].nil? == false
        teaser = teaser_doc.search('p')[1].text.strip
      end
    end
  elsif teaser_doc.search('h2').first.nil? && teaser_doc.search('h3').first.nil? && teaser_doc.at('.news_content').search('p')[0].nil? == false
    teaser_doc = teaser_doc.at('.news_content')
    teaser = teaser_doc.search('p')[0].text.strip
    if teaser.gsub(/[[:space:]]/, '') == '' && teaser_doc.search('p')[1].nil? == false
      teaser = teaser_doc.search('p')[1].text.strip
    end
  else
    teaser = article.strip
  end

  byebug
end

parse_page