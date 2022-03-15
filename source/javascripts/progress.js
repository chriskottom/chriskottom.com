/* Progress bar */
// Source: https://alligator.io/js/progress-bar-javascript-css-variables/
window.addEventListener('DOMContentLoaded', (event) => {
  let h = document.documentElement,
    b = document.body,
    st = 'scrollTop',
    sh = 'scrollHeight',
    progress = document.querySelector('#progress'),
    scroll
  let scrollpos = window.scrollY
  let header = document.getElementById('header')

  document.addEventListener('scroll', function() {

    /*Refresh scroll % width*/
    scroll = (h[st] || b[st]) / ((h[sh] || b[sh]) - h.clientHeight) * 100
    progress.style.setProperty('--scroll', scroll + '%')

    /*Apply classes for slide in bar*/
    scrollpos = window.scrollY

    if (scrollpos > 10) {
      header.classList.add('shadow')
    } else {
      header.classList.remove('shadow')
    }
  })
})
