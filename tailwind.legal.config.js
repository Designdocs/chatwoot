const base = require('./tailwind.config');

module.exports = {
  ...base,
  content: ['./app/views/layouts/legal.html.erb', './app/views/legal/**/*.erb'],
};
