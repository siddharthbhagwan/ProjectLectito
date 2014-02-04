// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.ui.all
//= require bootstrap
//= require dataTables/jquery.dataTables
//= require jquery.blockUI
//= require_tree .

$(document).ready(function() {

  // Function to Scroll to the top of the screen on page load
  window.scrollTo(0, 0);

  // Function for hover on menu

  /* When entering the menu, set a flag to show its open and current hover is on it. Classes for all three menus are the same
     No Id differentiation, thus the current flag is required */
  $(".header_hover").mouseenter(function() {
    if (!$(this).hasClass('open')) {
      $(this).click();
      $(this).addClass('header_hover_current');
    }
  });

  /* While leaving the main menu, wait for a 100ms , and then check for 3 cases - 1) Moved to sub menu 2) moved to menu that doesnt 
     have a sub like search or sign out 3) move to another menu with sub 
     Reference to 'this' is saved because inside the timeout fn, reference to calling obj is lost
     The delay is so that we give time for the mouseenter for sub menu or other menu. If this isnt done, if the mouse pointer moves 
     slowly from menu to sub menu, in the tiny border where it isnt in either classes, the mouseleave for main menu is called, which
     closes the sub before sub is entered */
  $(".header_hover").mouseleave(function() {
    var $this = $(this);
    setTimeout(function() {
      // OnMenu Signifies that pointer has moved to sub menu
      if (!$this.hasClass("onMenu")) {
        // Since not in sub menu, remove current
        $this.removeClass('header_hover_current');
        /* If theres isn't a current else where, means case 2, so click and blur
           If case 3, nothing to do as its enter would have called a click, which anyways removed the previous sub menu */
        if(!$(".header_hover_current").length) {
          $this.click();
          $this.blur();
        }
      }
    }, 100);
  });

  // On Entering a Sub Menu, set a flag
  $(".header_hover_sub").mouseenter(function() {
      $(this).prev().addClass('onMenu');
  });

  // On leaving a sub menu, close it, blur it, and remove the flags
  $(".header_hover_sub").mouseleave(function() {
    $(this).prev().click();
    $(this).prev().blur();
    $(this).prev().removeClass('onMenu');
    $(this).prev().removeClass('header_hover_current');
  });


});
