#= require_tree ./admin

moment.locale('de')
I18n.defaultLocale = 'de'

$.fn.twitter_bootstrap_confirmbox.defaults = {
  fade: false,
  title: I18n.t('js.modal.title')
}

###
# Fortune Cookie Reader v1.0
# Released under the MIT License
###
sayFortune = (fortune) ->
  console.log fortune # in bed!

class Horse extends Animal
  move: ->
    alert "Galloping..."
    super 45
