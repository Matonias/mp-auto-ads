class PagesController < ApplicationController
  def home

  end

  def login
    website = 'https://www.marktplaats.nl'

    # initialize Mechanize agent
    agent = Mechanize.new
    login_page = agent.get("#{website}/account/login.html")
    login_form = login_page.form
    email_field = login_form.field_with(name: "j_username")
    password_field = login_form.field_with(name: "j_password")
    success_url = login_form.field_with(name: 'success_url')

    # log in
    email_field.value =  ENV["mp-login"]
    password_field.value =  ENV["mp-pass"]
    login_form.submit

    # get ad page
    ad_search_results = JSON.parse(agent.get(search_json_url).body)
    ad_url = construct_ad_url(ad_search_results)

    # fill in ad page
    ad_page = agent.get(ad_url)
    ad_form = ad_page.form
    pp ad_page
    pp '============='
    pp ad_form

  end

  def search_json_url
    keywords = ['trui', 'heren']
    search_json_url = 'https://www.marktplaats.nl/syi/suggestedCategories.json?keywords='

    keywords.each do |keyword|
      keyword = keyword + '+'
      search_json_url += keyword
    end

    return search_json_url
  end

  def construct_ad_url(ad_data)
    ad_details = ad_data.first
    id = ad_details["id"]
    parent_id = ad_details["parentId"]
    bucket_id = ad_details["bucketId"]

    return "https://www.marktplaats.nl/syi/#{parent_id}/#{id}/plaatsAdvertentie.html?bucket=#{bucket_id}"
  end
end
