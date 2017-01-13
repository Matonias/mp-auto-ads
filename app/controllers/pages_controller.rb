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
    # ad_url = 'https://www.marktplaats.nl/syi/plaatsAdvertentie.html/m/save.html'
    # fill in ad page
    ad_page = agent.get(ad_url)
    ad_form = ad_page.form

    ad_form.field_with(name: 'title').value = 'Supreme+Araki+Trui'
    ad_form.field_with(name: 'price.value').value = '200'
    ad_form.field_with(name: 'contactInformation.postCode').value = '1165+LX'
    ad_form.field_with(name: 'description').value = 'Trui'

    ad_form.field_with(name: 'operation').value = ''

    ad_form.field_with(name: 'attribute[condition]').options[1].select
    ad_form.field_with(name: 'attribute[size]').options[2].select
    ad_form.field_with(name: 'attribute[color]').options[3].select

    ad_form.radiobuttons_with(name: 'country')[0].check
    ad_form.radiobuttons_with(name: 'priceType')[0].check
    ad_form.radiobuttons_with(name: 'price.bidding')[1].check
    ad_form.radiobuttons_with(name: 'price.bidding')[1].check

    ad_fields(ad_form, ad_search_results)

    query = {
      title: 'Araki',
      price: {
        value: '200',
        bidding: 'free-bidding',
        option: 'price'
      },
      complete: true,
      l1: '1776',
      l2: '652',
      bucket: '169',
      origin: 'HEADER',
      attribute: {
        condition: '30'
      },
      description: 'lol',
      priceType: 'on',
      contactInformation: {
        sellerName: 'eeee',
        postCode: '1165+LX'
      },
      country: 'on',
      showOnMap: 'on',
      "address-index-filter": "syi-address-nl",
      nl: {
        marktplaats: {
          xsrf: {
            token: "1484310457114.6e3f875c3b8b1b46a18eb125154c17c0"
          }
        }
      }
    }


    # response = agent.post('https://www.marktplaats.nl/syi/plaatsAdvertentie.html/m/save.html', query)
    # response = ad_page.link_with(dom_id: 'syi-place-ad-button')
    response = ad_page.response_read
    # response = ad_form.submit
    # response = ad_form.buttons.first.click_button
    buttons = ad_form.buttons

    pp ad_form
    pp '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    pp buttons
    pp '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    pp response
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

  def ad_fields(ad_form, ad_data)
    ad_details = ad_data.first
    id = ad_details["id"]
    parent_id = ad_details["parentId"]
    bucket_id = ad_details["bucketId"]

    ad_form.field_with(name: 'l1').value = parent_id
    ad_form.field_with(name: 'l2').value = id
    ad_form.field_with(name: 'bucket').value = bucket_id
    return ad_form
  end
end
