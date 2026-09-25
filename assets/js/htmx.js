import htmx from 'htmx.org';
import bootstrap from 'bootstrap/dist/js/bootstrap.bundle.min.js';

const toastTarget = (target, content)=> {
    //~ Replace target toast body with new content
    const body = document.querySelector('#' + target + ' .toast-body');
    body.innerHTML = content;

    //~ Then show toast
    const toastElement = document.getElementById(target);
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toastElement);
    toastBootstrap.show();
};

//~ Handle all htmx errors globally and trigger toast error with response detail
htmx.on('htmx:responseError', (event) => {
    toastTarget('toast-danger', '[ERROR] ' + event.detail.xhr.responseText);
});

htmx.on('htmx:sendAbort', (event) => {
    toastTarget('toast-danger', 'Request aborted!');
});

htmx.on('htmx:sendError', (event) => {
    toastTarget('toast-danger', 'Request cannot be sent!');
});

htmx.on('htmx:swapError', (event) => {
    toastTarget('toast-danger', 'Content cannot be swapped!');
});

htmx.on('htmx:targetError', (event) => {
    toastTarget('toast-danger', 'Error on target element!');
});

//~ Auto handle toast display after a swap content of toast success from htmx request
htmx.on('htmx:afterSwap', (event) => {
    if (event.detail.elt.id === 'toast-body-success') {
        const toastElement = document.getElementById('toast-success');
        const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toastElement);
        toastBootstrap.show();
    }
})
