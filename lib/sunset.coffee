{CompositeDisposable} = require 'atom'

module.exports = Sunset =
  config:
    daytime_syntax_theme:
      title: 'Daytime Theme (Syntax)'
      description: 'What syntax theme should I use during daylight?'
      default: atom.themes.getActiveThemeNames()[0]
      type: 'string'
      enum: atom.config.settings.core.themes
    daytime_ui_theme:
      title: 'Daytime Theme (UI)'
      description: 'What UI theme should I use during daylight?'
      default: atom.themes.getActiveThemeNames()[1]
      type: 'string'
      enum: atom.config.settings.core.themes
    nighttime_syntax_theme:
      title: 'Nighttime Theme (Syntax)'
      description: 'What syntax theme should I use during nighttime?'
      default: atom.themes.getActiveThemeNames()[0]
      type: 'string'
      enum: atom.config.settings.core.themes
    nighttime_ui_theme:
      title: 'Nighttime Theme (UI)'
      description: 'What UI theme should I use during nighttime?'
      default: atom.themes.getActiveThemeNames()[1]
      type: 'string'
      enum: atom.config.settings.core.themes
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
    {0:currentUiTheme, 1:currentSyntaxTheme} = atom.config.settings.core.themes

    @tock = setInterval () =>
      @tick()
    , 1 * 60 * 1000

    @setup()
    @bindEvents()
    @tick()

    # hack, but populate the settings so people can easily pick themes to change between
    @config.daytime_syntax_theme.enum =
      @config.nighttime_syntax_theme.enum =
      atom.themes.getLoadedThemes().filter((theme) -> theme.metadata.theme is 'syntax').map((theme) -> theme.name)
    @config.daytime_ui_theme.enum =
      @config.nighttime_ui_theme.enum =
      atom.themes.getLoadedThemes().filter((theme) -> theme.metadata.theme is 'ui').map((theme) -> theme.name)

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
    themes = atom.config.settings.core.themes.slice() # copy the array
    themes = @daytime_themes if twenty_four_hour >= atom.config.get('sunset.when_does_it_get_light')
    themes = @nighttime_themes if twenty_four_hour >= atom.config.get('sunset.when_does_it_get_dark')

    # store the theme change :D
    atom.config.set('core.themes', themes) if themes[0] != atom.config.settings.core.themes[0] || themes[1] != atom.config.settings.core.themes[1]

  deactivate: ->
    @subscriptions.dispose()

  serialize: -> null
