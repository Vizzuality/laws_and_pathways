const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.loaders.append('eslint', {
  enforce: 'pre',
  test: /\.js$/,
  use: 'eslint-loader',
  exclude: /node_modules/
});

module.exports = environment
