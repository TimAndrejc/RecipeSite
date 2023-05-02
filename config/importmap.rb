# config/importmap.rb

pin "application", preload: true
pin "@rails/actioncable", to: "actioncable.js"
pin "@rails/ujs", to: "ujs.js"
pin "@rails/activestorage", to: "activestorage.js"
pin "@hotwired/turbo-rails", to: "turbo.js"
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "local-time", to: "local-time.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin  "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"