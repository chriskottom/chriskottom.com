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
end
