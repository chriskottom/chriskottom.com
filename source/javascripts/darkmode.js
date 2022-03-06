const button = document.getElementById('dark-mode-button')
const html_element = document.querySelector('html')

let dark_mode_boolean = false

button.addEventListener('click', () => {
    //checking if the dark mode as already been
    if(!localStorage.getItem('dark-mode')) {
        localStorage.setItem('dark-mode', dark_mode_boolean)
    }
    if(localStorage.getItem('dark-mode') === true) {
        localStorage.getItem('dark-mode') === false
    } else if(localStorage.getItem('dark-mode') === false) {
        localStorage.getItem('dark-mode') === true
    }
})

if(localStorage.getItem('dark-mode') === true ) {
    html_element.classList.add('dark')
} else if(localStorage.getItem('dark-mode') === false) {
    html_element.classList.remove('dark')
}