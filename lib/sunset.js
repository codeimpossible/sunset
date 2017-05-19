var CompositeDisposable, Sunset, cached_themes;

CompositeDisposable = require('atom').CompositeDisposable;

cached_themes = {
  ui: [],
  syntax: []
};

module.exports = Sunset = {
  config: {
    daytime_syntax_theme: {
      title: 'Daytime Theme (Syntax)',
      description: 'What syntax theme should I use during daylight?',
      type: 'string',
      "default": 'atom-light-syntax'
    },
    daytime_ui_theme: {
      title: 'Daytime Theme (UI)',
      description: 'What UI theme should I use during daylight?',
      type: 'string',
      "default": 'atom-light-ui'
    },
    nighttime_syntax_theme: {
      title: 'Nighttime Theme (Syntax)',
      description: 'What syntax theme should I use during nighttime?',
      type: 'string',
      "default": 'atom-dark-syntax'
    },
    nighttime_ui_theme: {
      title: 'Nighttime Theme (UI)',
      description: 'What UI theme should I use during nighttime?',
      type: 'string',
      "default": 'atom-dark-ui'
    },
    when_does_it_get_dark: {
      title: 'When does nighttime start?',
      description: 'When (in 24hr format) does the sun set?',
      "default": 1800,
      minimum: 0,
      maximum: 2400,
      type: 'number'
    },
    when_does_it_get_light: {
      title: 'When does daytime start?',
      description: 'When (in 24hr format) does the sun rise?',
      "default": 500,
      minimum: 0,
      maximum: 2400,
      type: 'number'
    },
    has_been_configured: {
      title: 'This plugin has been configured?',
      description: 'Internal state tracking. Don\'t change this yourself unless you are ok with bugs.',
      "default": false,
      type: 'boolean'
    }
  },
  subscriptions: null,
  activate: function(state) {
    this.tock = setInterval((function(_this) {
      return function() {
        return _this.tick();
      };
    })(this), 1 * 60 * 1000);
    this.setup();
    this.bindEvents();
    this.tick();
    atom.themes.getLoadedThemes().forEach(function(theme) {
      if (theme.metadata.theme === 'ui') {
        cached_themes.ui.push(theme.name);
      }
      if (theme.metadata.theme === 'syntax') {
        return cached_themes.syntax.push(theme.name);
      }
    });
    this.config.daytime_syntax_theme.description = this.config.nighttime_syntax_theme.description = 'Values can be `' + cached_themes.syntax.join(', ') + '`';
    this.config.daytime_ui_theme.description = this.config.nighttime_ui_theme.description = 'Values can be `' + cached_themes.ui.join(', ') + '`';
    return this.subscriptions = new CompositeDisposable;
  },
  bindEvents: function() {
    atom.config.observe('sunset.nighttime_ui_theme', (function(_this) {
      return function(value) {
        atom.config.set('sunset.has_been_configured', true);
        _this.setup();
        return _this.tick();
      };
    })(this));
    atom.config.observe('sunset.nighttime_syntax_theme', (function(_this) {
      return function(value) {
        atom.config.set('sunset.has_been_configured', true);
        _this.setup();
        return _this.tick();
      };
    })(this));
    atom.config.observe('sunset.daytime_ui_theme', (function(_this) {
      return function(value) {
        atom.config.set('sunset.has_been_configured', true);
        _this.setup();
        return _this.tick();
      };
    })(this));
    return atom.config.observe('sunset.daytime_syntax_theme', (function(_this) {
      return function(value) {
        atom.config.set('sunset.has_been_configured', true);
        _this.setup();
        return _this.tick();
      };
    })(this));
  },
  setup: function() {
    this.daytime_themes = [atom.config.get('sunset.daytime_ui_theme'), atom.config.get('sunset.daytime_syntax_theme')];
    return this.nighttime_themes = [atom.config.get('sunset.nighttime_ui_theme'), atom.config.get('sunset.nighttime_syntax_theme')];
  },
  tick: function() {
    var current_theme_names, now, themes, twenty_four_hour;
    if (!atom.config.get('sunset.has_been_configured')) {
      return;
    }
    now = new Date;
    twenty_four_hour = (now.getHours() * 100) + now.getMinutes();
    current_theme_names = atom.themes.getActiveThemeNames();
    themes = current_theme_names.slice();
    if (twenty_four_hour >= atom.config.get('sunset.when_does_it_get_light')) {
      themes = this.daytime_themes;
    }
    if (twenty_four_hour >= atom.config.get('sunset.when_does_it_get_dark')) {
      themes = this.nighttime_themes;
    }
    if (twenty_four_hour < atom.config.get('sunset.when_does_it_get_light')) {
      themes = this.nighttime_themes;
    }
    if (themes.filter(function(t) {
      return current_theme_names.indexOf(t) > -1;
    }).length !== current_theme_names.length) {
      return atom.config.set('core.themes', themes);
    }
  },
  deactivate: function() {
    return this.subscriptions.dispose();
  },
  serialize: function() {
    return null;
  }
};
