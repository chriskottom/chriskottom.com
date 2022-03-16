# Site settings
# https://middlemanapp.com/advanced/configuration/
set :author, "Chris Kottom"
set :title, "Chris Kottom's Tech and Business Blog"
set :description, "Chris Kottom writes about programming, software development, business, and bootstrapping."


# Activate and configure blog extension
# https://middlemanapp.com/basics/blogging/
activate :blog do |blog|
  blog.prefix = "articles"
  blog.layout = "article"

  blog.sources = "{year}-{month}-{day}-{title}/index.html"
  blog.default_extension = ".markdown"
  blog.summary_length = 250
  blog.permalink = "{title}"

  blog.paginate = false

  blog.generate_day_pages = false
  blog.generate_month_pages = false
  blog.generate_year_pages = false
  blog.generate_tag_pages = false
end


# Activate and configure other extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions
activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :syntax, line_numbers: true, css_class: 'codehilite'
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true


# Layouts
# https://middlemanapp.com/basics/layouts/
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
# page '/path/to/file.html', layout: 'other_layout'


# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }


# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/
require "helpers/site_helpers"
helpers SiteHelpers


# External pipeline
# Using Webpack to build a single file containing all your JS and CSS
# https://middlemanapp.com/advanced/external-pipeline/
activate :external_pipeline,
  name: :webpack,
  command: build? ? "npm run build" : "npm run start",
  source: ".tmp/dist",
  latency: 1


# Development environment-specific configuration
# Reload the browser automatically whenever files change
configure :development do
  config[:css_dir] = ".tmp/dist"
  config[:js_dir] = ".tmp/dist"
  # activate :livereload
end


# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings
configure :build do
  activate :minify_css
  activate :minify_javascript
end
