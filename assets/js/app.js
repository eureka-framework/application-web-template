//~ Imports
import bootstrap from 'bootstrap/dist/js/bootstrap.bundle.min.js';
import Choices from 'choices.js';
import './dark.js';
import './htmx.js';

const initApp = () => {

    const toastTriggerList = document.querySelectorAll('[data-bs-toggle="toast"]');
    toastTriggerList.forEach((btn) => {
        btn.addEventListener('click', (event) => {
            event.preventDefault();
            const toastElement = document.getElementById(btn.getAttribute('data-bs-target'));
            const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toastElement);
            toastBootstrap.show();
        });
    });

    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltipTriggerList.forEach((tooltipTriggerEl) => {
        new bootstrap.Tooltip(tooltipTriggerEl);
    });

    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
    popoverTriggerList.forEach((popoverTriggerEl) => {
        new bootstrap.Popover(popoverTriggerEl); // eslint-disable-line no-new
    });

    const selects = document.querySelectorAll('.js-choice');
    selects.forEach(element => {
        new Choices(element, {allowHTML: true, removeItemButton: true})
    })

    const selectsEditable = document.querySelectorAll('.js-choice-editable');
    selectsEditable.forEach(element => {
        new Choices(element, {allowHTML: true, removeItemButton: true, addItems: true, addChoices: true})
    })

}

document.addEventListener('DOMContentLoaded', () => {
    initApp();
});
