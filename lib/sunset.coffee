{CompositeDisposable} = require 'atom'

cached_themes =
  ui: []
  syntax: []
times = [
  { value: 0, description: '0:00 (12AM)' },
  { value: 100, description: '1:00 (1AM)' },
  { value: 200, description: '2:00 (2AM)' },
  { value: 300, description: '3:00 (3AM)' },
  { value: 400, description: '4:00 (4AM)' },
  { value: 500, description: '5:00 (5AM)' },
  { value: 600, description: '6:00 (6AM)' },
  { value: 700, description: '7:00 (7AM)' },
  { value: 800, description: '8:00 (8AM)' },
  { value: 900, description: '9:00 (9AM)' },
  { value: 1000, description: '10:00 (10AM)' },
  { value: 1100, description: '11:00 (11AM)' },
  { value: 1200, description: '12:00 (12PM)' },
  { value: 1300, description: '13:00 (1PM)' },
  { value: 1400, description: '14:00 (2PM)' },
  { value: 1500, description: '15:00 (3PM)' },
  { value: 1600, description: '16:00 (4PM)' },
  { value: 1700, description: '17:00 (5PM)' },
  { value: 1800, description: '18:00 (6PM)' },
  { value: 1900, description: '19:00 (7PM)' },
  { value: 2000, description: '20:00 (8PM)' },
  { value: 2100, description: '21:00 (9PM)' },
  { value: 2200, description: '22:00 (10PM)' },
  { value: 2300, description: '23:00 (11PM)' }
]

module.exports = Sunset =
  config:
    daytime_syntax_theme:
      title: 'Daytime Syntax Theme'
      description: 'What syntax theme should I use during the day?'
      type: 'string'
      default: 'one-light-syntax'
      enum: cached_themes.syntax
    daytime_ui_theme:
      title: 'Daytime UI Theme'
      description: 'What UI theme should I use during the day?'
      type: 'string'
      default: 'one-light-ui'
      enum: cached_themes.ui
    nighttime_syntax_theme:
      title: 'Night-time Syntax Theme'
      description: 'What syntax theme should I use during the night?'
      type: 'string'
      default: 'one-dark-syntax'
      enum: cached_themes.syntax
    nighttime_ui_theme:
      title: 'Night-time UI Theme'
      description: 'What UI theme should I use during the night?'
      type: 'string'
      default: 'one-dark-ui'
      enum: cached_themes.ui
    when_does_it_get_dark:
      title: 'When does the sun set?'
      description: 'Use a 24hr format: 8:00PM equals 20:00, so type 2000'
      default: 1800
      minimum: 0
      maximum: 2400
      type: 'number'
      enum: times
    when_does_it_get_light:
      title: 'When does the sun rise?'
      description: 'Use a 24hr format: 8:00PM equals 20:00, so type 2000'
      default: 500
      minimum: 0
      maximum: 2400
      type: 'number'
      enum: times
    has_been_configured:
      title: 'This plugin has been configured?'
      description: 'Internal state tracking. Don\'t change this yourself unless you are ok with bugs.'
      default: false
      type: 'boolean'

  subscriptions: null

  activate: (state) ->
    @tock = setInterval () =>
      @tick()
    , 1 * 60 * 1000

    @setup()
    @bindEvents()
    @tick()
    
    createThemeMenuItem = (themeName) ->
      themeName.replace(/-(ui|syntax)/g, '').replace(/-theme$/g, '').replace(/-/g, ' ').replace(/([a-z])([A-Z])/g, '$1 $2').replace(/\b([A-Z]+)([A-Z])([a-z])/, '$1 $2$3').replace /^./, (s) ->
        s.toUpperCase()

    atom.themes.getLoadedThemes().forEach (theme) ->
      cached_themes.ui.push({ value: theme.name, description: createThemeMenuItem(theme.name) }) if theme.metadata.theme is 'ui'
      cached_themes.syntax.push({ value: theme.name, description: createThemeMenuItem(theme.name) }) if theme.metadata.theme is 'syntax'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

  bindEvents: ->
    atom.config.observe 'sunset.nighttime_ui_theme', (value) =>
      atom.config.set('sunset.has_been_configured', true)
      @setup()
      @tick()

    atom.config.observe 'sunset.nighttime_syntax_theme', (value) =>
      atom.config.set('sunset.has_been_configured', true)
      @setup()
      @tick()

    atom.config.observe 'sunset.daytime_ui_theme', (value) =>
      atom.config.set('sunset.has_been_configured', true)
      @setup()
      @tick()

    atom.config.observe 'sunset.daytime_syntax_theme', (value) =>
      atom.config.set('sunset.has_been_configured', true)
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
    return unless atom.config.get('sunset.has_been_configured')
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
