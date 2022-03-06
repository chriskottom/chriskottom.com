window.addEventListener('DOMContentLoaded', (event) => {
    document.getElementById('dark-mode-button').addEventListener('click', () => {
        if (localStorage.getItem('darkMode') === 'true') {
            localStorage.setItem('darkMode', false)
            document.documentElement.classList.remove('dark')
        } else {
            localStorage.setItem('darkMode', true)
            document.documentElement.classList.add('dark')
        }
    })
})
