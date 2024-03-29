---
changefreq: weekly
priority: 1
---
xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  sitemap.resources.select { |page| page.path =~ /\.html/ }.each do |page|
    xml.url do
      xml.loc "#{data.sitemap.url}#{page.destination_path}"
      xml.lastmod last_modified(page).to_time.iso8601
      xml.changefreq current_page.data.changefreq || 'monthly'
      xml.priority current_page.data.priority || '0.5'
    end
  end
end
