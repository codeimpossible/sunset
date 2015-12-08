{CompositeDisposable} = require 'atom'

cached_themes =
  ui: []
  syntax: []

module.exports = Sunset =
  config:
    daytime_syntax_theme:
      title: 'Daytime Theme (Syntax)'
      description: 'What syntax theme should I use during daylight?'
      type: 'string'
      default: 'atom-light-syntax'
    daytime_ui_theme:
      title: 'Daytime Theme (UI)'
      description: 'What UI theme should I use during daylight?'
      type: 'string'
      default: 'atom-light-ui'
    nighttime_syntax_theme:
      title: 'Nighttime Theme (Syntax)'
      description: 'What syntax theme should I use during nighttime?'
      type: 'string'
      default: 'atom-dark-syntax'
    nighttime_ui_theme:
      title: 'Nighttime Theme (UI)'
      description: 'What UI theme should I use during nighttime?'
      type: 'string'
      default: 'atom-dark-ui'
    when_does_it_get_dark:
      title: 'When does nighttime start?'
      description: 'When (in 24hr format) does the sun set?'
      default: 1800
      minimum: 0
      maximum: 2400
      type: 'number'
    when_does_it_get_light:
      title: 'When does daytime start?'
      description: 'When (in 24hr format) does the sun rise?'
      default: 500
      minimum: 0
      maximum: 2400
      type: 'number'

  subscriptions: null

  activate: (state) ->
    @tock = setInterval () =>
      @tick()
    , 1 * 60 * 1000

    @setup()
    @bindEvents()
    @tick()

    atom.themes.getLoadedThemes().forEach (theme) ->
      cached_themes.ui.push(theme.name) if theme.metadata.theme is 'ui'
      cached_themes.syntax.push(theme.name) if theme.metadata.theme is 'syntax'

    @config.daytime_syntax_theme.description =
      @config.nighttime_syntax_theme.description =
        'Values can be `' + cached_themes.syntax.join(', ') + '`'

    @config.daytime_ui_theme.description =
      @config.nighttime_ui_theme.description =
        'Values can be `' + cached_themes.ui.join(', ') + '`'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

  bindEvents: ->
    atom.config.onDidChange 'sunset.nighttime_ui_theme', ({newValue, oldValue}) =>
      @setup()
      @tick()

    atom.config.onDidChange 'sunset.nighttime_syntax_theme', ({newValue, oldValue}) =>
      @setup()
      @tick()

    atom.config.onDidChange 'sunset.daytime_ui_theme', ({newValue, oldValue}) =>
      @setup()
      @tick()

    atom.config.onDidChange 'sunset.daytime_syntax_theme', ({newValue, oldValue}) =>
      @setup()
      @tick()

  setup: ->
    @daytime_themes = [
      atom.config.get('sunset.daytime_ui_theme'),
      atom.config.get('sunset.daytime_syntax_theme')
    ]

    @nighttime_themes = [
      atom.config.get('sunset.nighttime_ui_theme'),
      atom.config.get('sunset.nighttime_syntax_theme')
    ]

  tick: ->
    now = new Date
    twenty_four_hour = (now.getHours() * 100) + now.getMinutes()
    current_theme_names = atom.themes.getActiveThemeNames()
    themes = current_theme_names.slice() # copy the array
    themes = @daytime_themes if twenty_four_hour >= atom.config.get('sunset.when_does_it_get_light')
    themes = @nighttime_themes if twenty_four_hour >= atom.config.get('sunset.when_does_it_get_dark')
    themes = @nighttime_themes if twenty_four_hour < atom.config.get('sunset.when_does_it_get_light')

    # store the theme change :D
    atom.config.set('core.themes', themes) unless themes.filter((t) -> current_theme_names.indexOf(t) > -1).length == current_theme_names.length

  deactivate: ->
    @subscriptions.dispose()

  serialize: -> null
