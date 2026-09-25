'use strict';
const THEME_KEY = 'app_theme'

/**
 * @param {"dark"|"light"} theme
 * @param {boolean} persist
 */
function setTheme(theme, persist = false) {
    document.documentElement.setAttribute('data-bs-theme', theme);

    if (persist) {
        localStorage.setItem(THEME_KEY, theme);
    }
}

/**
 * Init theme from setTheme()
 */
function initTheme() {
    //If the user manually set a theme, we'll load that
    const storedTheme = localStorage.getItem(THEME_KEY)
    if (storedTheme) {
        return setTheme(storedTheme)
    }
    //Detect if the user set his preferred color scheme to dark
    if (!window.matchMedia) {
        return
    }

    //Media query to detect dark preference
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')

    //Register change listener
    mediaQuery.addEventListener('change', (e) =>
        setTheme(e.matches ? 'dark' : 'light', true)
    )
    return setTheme(mediaQuery.matches ? 'dark' : 'light', true)
}

window.addEventListener('DOMContentLoaded', () => {

    document.querySelectorAll('[data-bs-theme-value]').forEach(value => {
        value.addEventListener('click', () => {
            const theme = value.getAttribute('data-bs-theme-value');
            setTheme(theme, true);
        });
    });

    initTheme();
});
