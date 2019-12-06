process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');
const eslint = require('./plugins/eslint');

eslint(environment);

module.exports = environment.toWebpackConfig();
