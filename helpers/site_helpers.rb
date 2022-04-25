module SiteHelpers
  def page_url
    current_page.url
  end

  def page_author
    (current_page && current_page.data.author) || config[:author]
  end

  def page_title
    (current_article && current_article.title) ||
      (current_page && current_page.data.title) ||
      config[:title]
  end

  def page_description
    (current_page && current_page.data.description) || config[:description]
  end

  def page_keywords
    current_page.data.keywords
  end

  def page_image
    current_page.data.image
  end

  def last_modified(page = current_page)
    date = Date.parse(page.data.last_modified) if page.data.last_modified
    date ||= Date.parse(page.data.date) if page.data.date
    date || Date.today
  end
end
