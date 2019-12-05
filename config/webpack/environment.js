const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.loaders.append('eslint', {
  enforce: 'pre',
  test: /\.js$/,
  loader: 'eslint-loader',
  exclude: /node_modules/,
  options: {
    emitWarning: true,
    failOnWarning: false
  }
});

module.exports = environment
