const CompositeDisposable = require('atom').CompositeDisposable;
const request = require('request-promise');
const SunCalc = require('suncalc');

const TICK_INTERVAL = 60000; // one minute

/* eslint-disable object-property-newline */
const TIMES = [
    { value: 0, description: '12 AM' },
    { value: 100, description: '1 AM' },
    { value: 200, description: '2 AM' },
    { value: 300, description: '3 AM' },
    { value: 400, description: '4 AM' },
    { value: 500, description: '5 AM' },
    { value: 600, description: '6 AM' },
    { value: 700, description: '7 AM' },
    { value: 800, description: '8 AM' },
    { value: 900, description: '9 AM' },
    { value: 1000, description: '10 AM' },
    { value: 1100, description: '11 AM' },
    { value: 1200, description: '12 PM' },
    { value: 1300, description: '1 PM' },
    { value: 1400, description: '2 PM' },
    { value: 1500, description: '3 PM' },
    { value: 1600, description: '4 PM' },
    { value: 1700, description: '5 PM' },
    { value: 1800, description: '6 PM' },
    { value: 1900, description: '7 PM' },
    { value: 2000, description: '8 PM' },
    { value: 2100, description: '9 PM' },
    { value: 2200, description: '10 PM' },
    { value: 2300, description: '11 PM' }
];
/* eslint-enable object-property-newline */

const cachedThemes = {
    ui: [],
    syntax: []
};

module.exports = {
    hasBeenConfigured: false,
    config: {
        /* eslint-disable camelcase */
        daytime_syntax_theme: {
            title: 'Daytime Syntax Theme',
            description: 'What syntax theme should I use during the day?',
            type: 'string',
            default: 'atom-light-syntax',
            enum: cachedThemes.syntax
        },
        daytime_ui_theme: {
            title: 'Daytime UI Theme',
            description: 'What UI theme should I use during the day?',
            type: 'string',
            default: 'atom-light-ui',
            enum: cachedThemes.ui
        },
        nighttime_syntax_theme: {
            title: 'Nighttime Syntax Theme',
            description: 'What syntax theme should I use during the night?',
            type: 'string',
            default: 'atom-dark-syntax',
            enum: cachedThemes.syntax
        },
        nighttime_ui_theme: {
            title: 'Nighttime UI Theme',
            description: 'What UI theme should I use during the night?',
            type: 'string',
            default: 'atom-dark-ui',
            enum: cachedThemes.ui
        },
        use_geolocation: {
            title: 'Use Geolocation',
            description: `Use your geolocation (via http://freegeoip.net) to automatically determine sun set/rise times
                based on the current date. If this setting is checked, the sun set/rise settings below are
                automtically updated.`,
            type: 'boolean',
            default: true
        },
        when_does_it_get_dark: {
            title: 'When does the sun set?',
            default: 1800,
            minimum: 0,
            maximum: 2400,
            type: 'number',
            enum: TIMES
        },
        when_does_it_get_light: {
            title: 'When does the sun rise?',
            default: 500,
            minimum: 0,
            maximum: 2400,
            type: 'number',
            enum: TIMES
        }
        /* eslint-enable camelcase */
    },
    subscriptions: null,
    activate() {
        setInterval(this.tick, TICK_INTERVAL);
        this.setup();
        this.bindEvents();
        this.tick();
        atom.themes.getLoadedThemes().forEach(theme => {
            if (theme.metadata.theme === 'ui') {
                cachedThemes.ui.push(theme.name);
            }
            if (theme.metadata.theme === 'syntax') {
                cachedThemes.syntax.push(theme.name);
            }
        });

        this.subscriptions = new CompositeDisposable();

        // clean up old configs
        const hasBeenConfigured = 'sunset.has_been_configured';
        if (atom.config.get(hasBeenConfigured) !== undefined) {
            atom.config.unset(hasBeenConfigured);
        }
    },
    getLocation() {
        const url = 'http://freegeoip.net/json/';
        request.get(url).then(response => {
            const { latitude, longitude } = JSON.parse(response);
            const times = SunCalc.getTimes(Date.now(), latitude, longitude);

            atom.config.set('sunset.when_does_it_get_light', this.getTwentyFourHourTime(times.nauticalDawn));
            atom.config.set('sunset.when_does_it_get_dark', this.getTwentyFourHourTime(times.nauticalDusk));
        }).catch(error => {
            atom.notifications.addError('Error getting geolocation/sun times!', {
                description: error.message,
                dismissable: true
            });
        });
    },
    bindEvents() {
        const onConfigChange = () => {
            this.hasBeenConfigured = true;
            this.setup();

            this.tick();
        };

        atom.config.observe('sunset.nighttime_ui_theme', (onConfigChange));
        atom.config.observe('sunset.nighttime_syntax_theme', (onConfigChange));
        atom.config.observe('sunset.daytime_ui_theme', (onConfigChange));
        atom.config.observe('sunset.daytime_syntax_theme', (onConfigChange));

        atom.config.observe('sunset.use_geolocation', (() => {
            this.setup();
        }));
    },
    setup() {
        this.daytimeThemes = [
            atom.config.get('sunset.daytime_ui_theme'),
            atom.config.get('sunset.daytime_syntax_theme')
        ];

        this.nighttimeThemes = [
            atom.config.get('sunset.nighttime_ui_theme'),
            atom.config.get('sunset.nighttime_syntax_theme')
        ];

        if (atom.config.get('sunset.use_geolocation')) {
            this.getLocation();
        }
    },
    getTwentyFourHourTime(date) {
        const hoursToMinutesFactor = 100;

        return (date.getHours() * hoursToMinutesFactor) + date.getMinutes();
    },
    tick() {
        if (!this.hasBeenConfigured) {
            return;
        }

        const twentyFourHour = this.getTwentyFourHourTime(new Date());
        const currentThemeNames = atom.themes.getActiveThemeNames();
        let themes = currentThemeNames.slice();
        if (twentyFourHour >= atom.config.get('sunset.when_does_it_get_light')) {
            themes = this.daytimeThemes;
        }
        if (twentyFourHour >= atom.config.get('sunset.when_does_it_get_dark')) {
            themes = this.nighttimeThemes;
        }
        if (twentyFourHour < atom.config.get('sunset.when_does_it_get_light')) {
            themes = this.nighttimeThemes;
        }
        if (themes.filter((t) => {
            return currentThemeNames.indexOf(t) > -1;
        }).length !== currentThemeNames.length) {
            atom.config.set('core.themes', themes);
        }
    },
    deactivate() {
        this.subscriptions.dispose();
    },
    serialize() {
        return null;
    }
};
