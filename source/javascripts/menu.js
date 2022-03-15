window.addEventListener('DOMContentLoaded', (event) => {
  document.getElementById('nav-toggle').onclick = function() {
    document.getElementById('nav-content').classList.toggle('hidden')
  }
})
