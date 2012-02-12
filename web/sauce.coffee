
jQuery ->
    
    CGI = 'http://saucesum.no-ip.org/cgi-bin/dev/testsauce'
    
    # Images
    IMG_EDIT =
        url  : "img/edit_item.png"
        class: 'img-edit'
        title: 'Edit'
        
    IMG_DELETE =
        url  : "img/delete_item.png"
        class: 'img-remove'
        title: 'Remove'


    # Cache
    DATA     = {}
    selected = null
    channel  = null

    
    filter_buttons =
        'filter-url'   : 'url'
        'filter-caps'  : 'caps'
        'filter-words' : 'words'
        'filter-emotes': 'emotes'


    $(element).hide() for element in [
        '#error-box'
        '#num-editor'
        
        '#filters'
        '#tab-whitelist'
        '#tab-blacklist'
        '#tab-badwords'
        '#tab-emotes'
    ]
    
    
    channel = $('#channel-select').val()
    
    jQuery.fn.extend
          # Disables the input field and adds the class 'input-disabled'
          disable: ->
            $(@).toggleClass('input-disabled', true)
                .attr('disabled', 'disabled')
                
          # Enables the input field and removes the class 'input-disabled' 
          , enable: ->
            $(@).toggleClass('input-disabled', false)
                .removeAttr 'disabled'
                

    show_error = (msg) ->
        $('#error-box'    ).fadeIn 'slow'
        $('#error-box div').text msg
        
        setTimeout ->
            $('#error-box').fadeOut 'slow'
        , 5000
        
    # Sends a CGI request to the back-end server
    cgi = (act, type, key, value, callback) ->
        $.getJSON CGI,
            chanid: channel
            act   : act
            type  : type
            key   : key
            value : value
        , callback
        
