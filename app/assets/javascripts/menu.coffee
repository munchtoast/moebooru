$ = jQuery

$(document).on 'click', '#login-link', (e) ->
  e.preventDefault()
  User.run_login false, ->
    window.location = window.location
    return
  return
$(document).on 'click', '#forum-mark-all-read', ->
  Forum.mark_all_read()
  false
window.Menu =
  menu: null
  set_post_moderate_count: ->
    mod_pending = parseInt(Cookies('mod_pending'))
    if mod_pending > 0
      mod_link = @menu.find('.moderate')
      mod_link.text(mod_link.text() + ' (' + mod_pending + ')').addClass 'bolded'
    return
  set_highlight: ->
    hl_menu_class = '.' + @menu.data('controller')
    @menu.find(hl_menu_class).addClass 'current-menu'
    return
  hide_help_items: ->
    nohide_menu_class = '.help-item.' + @menu.data('controller')
    @menu.find('.help-item').hide()
    @menu.find(nohide_menu_class).show()
    return
  show_search_box: (elem) ->
    submenu = $(elem).parents('.submenu')
    search_box = submenu.siblings('.search-box')
    search_text_box = search_box.find('[type="text"]')

    hide = (e) ->
      search_box.hide()
      search_box.removeClass 'is_modal'
      search_text_box.removeClass 'mousetrap'
      return

    show = ->
      $('.submenu').hide()
      search_box.show()
      search_box.addClass 'is_modal'
      search_text_box.addClass('mousetrap').focus()

      document_click_event = (e) ->
        if $(e.target).parents('.is_modal').length == 0 and !$(e.target).hasClass('is_modal')
          hide e
          $(document).off 'mousedown', '*', document_click_event
        return

      $(document).on 'mousedown', '*', document_click_event
      Mousetrap.bind 'esc', hide
      return

    show()
    false
  sync_forum_menu: ->
    self = this
    $.get Moebooru.path('/forum.json'), { latest: 1 }, (resp) ->
      last_read = Cookies.getJSON('forum_post_last_read_at')
      forum_menu_items = resp
      forum_submenu = $('li.forum ul.submenu', self.menu)
      forum_items_start = forum_submenu.find('.forum-items-start').show()

      create_forum_item = (post_data) ->
        $ '<li/>', html: $('<a/>',
          href: Moebooru.path('/forum/show/' + post_data.id + '?page=' + post_data.pages)
          text: post_data.title
          title: post_data.title
          class: if post_data.updated_at > last_read then 'unread-topic' else null)

      # Reset latest topics.
      forum_items_start.nextAll().remove()
      if forum_menu_items.length > 0
        $.each forum_menu_items, (_i, post_data) ->
          forum_submenu.append create_forum_item(post_data)
          forum_items_start.show()
          return
        # Set correct class based on read/unread.
        if forum_menu_items.first().updated_at > last_read
          $('#forum-link').addClass 'forum-update'
          $('#forum-mark-all-read').show()
        else
          $('#forum-link').removeClass 'forum-update'
          $('#forum-mark-all-read').hide()
      return
    return
  init: ->
    @menu = $('#main-menu')
    @set_highlight()
    @set_post_moderate_count()
    @sync_forum_menu()
    @hide_help_items()

    ###
    # Shows #cn
    # FIXME: I have no idea what this is for.
    ###

    $('#cn').show()
    return
