const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: {
    site: ['./source/javascripts/site.js'],
    style: ['./source/stylesheets/site.css', './source/stylesheets/highlighting.css'],
  },
  output: {
    path: path.resolve(__dirname, '.tmp/dist'),
    filename: '[name].min.js',
  },
  module: {
    rules: [
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader'
        ],
      }
    ]
  },
  plugins: [new MiniCssExtractPlugin()],
}
