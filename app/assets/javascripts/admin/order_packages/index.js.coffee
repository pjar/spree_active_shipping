$ ->
  ($ '#new_order_package_link').click (event) ->
    event.preventDefault()

    ($ '.no-objects-found').hide()

    ($ this).hide()
    $.ajax
      type: 'GET'
      url: @href
      data: (
        authenticity_token: AUTH_TOKEN
      )
      success: (r) ->
        ($ '#order_packages').html r

  ($ 'a.edit').click (event) ->
    event.preventDefault()

    ($ '#order_packages').html('')
    $.ajax
      type: 'GET'
      url: @href
      data: (
        authenticity_token: AUTH_TOKEN
      )
      success: (r) ->
        ($ '#order_packages').html r
