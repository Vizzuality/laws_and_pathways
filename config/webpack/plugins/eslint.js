module.exports = function (environment) {
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
};
