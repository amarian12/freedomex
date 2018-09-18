#= require yarn_components/raven-js/dist/raven
#= require ./lib/sentry

#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require scrollIt
#= require bignumber
#= require underscore
#= require clipboard
#= require pusher.min
#= require qrcode

#= require ./lib/pusher_connection
#= require ./lib/tiny-pubsub

#= require pusher.min
#= require angular
#= require angular-resource
#= require ./lib/angular-ui-router
#= require ./lib/peatio_model
#= require ./lib/ajax
#= require ./lib/pusher_subscriber
#= require ./dashboard/dashboard
#= require jquery.flexisel

$ ->
  BigNumber.config(ERRORS: false)

  $('[data-clipboard-text], [data-clipboard-target]').each ->
      clipboard = new Clipboard(this)

  if $('#assets-index').length
    $.scrollIt
      topOffset: -180
      activeClass: 'active'

    $('a.go-verify').on 'click', (e) ->
      e.preventDefault()

      root         = $('.tab-pane.active .root.json pre').text()
      partial_tree = $('.tab-pane.active .partial-tree.json pre').text()

      if partial_tree
        uri = 'http://syskall.com/proof-of-liabilities/#verify?partial_tree=' + partial_tree + '&expected_root=' + root
        window.open(encodeURI(uri), '_blank')

  $('.qrcode-container').each (index, el) ->
    $el = $(el)
    new QRCode el,
      text:   $el.data('text')
      width:  $el.data('width')
      height: $el.data('height')
