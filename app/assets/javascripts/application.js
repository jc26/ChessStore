// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
//= require semantic-ui

$(function() {
  // $('#welcome-text').css({display:'block'}).animate({marginTop:'80px', opacity:'1'},500);
  var windowHeight = window.innerHeight;
  var mainDiv = $('.main-signed-out');
  var mdHeight = mainDiv.height();
  if (windowHeight > mdHeight) {
    mainDiv.css('height', '100%');
  }
  resizeBGImage();
  window.onresize = resizeBGImage();
  function resizeBGImage() {
    var sidebar = $('.sidebar');
    mainDiv.css('background-position', 'left ' + sidebar.width() + 'px bottom');
  }
  $("#cart").on("click", function() {
    $(".shopping-cart").fadeToggle("fast");
  });
  $('.alert-box').delay(500).fadeIn('normal', function() {
      $(this).delay(3000).fadeOut();
  });
  $('a.close').on('click', function() {
    $(this).parent().remove();
  });
  window.onload = function() {
    $('div.input.select.optional.school_state.error').css('margin-left', '0px');
    $('.simple_form.error').css('margin-left', '0px');
    $('small.error').css('margin-left', '0px');
  }
});

// window.onload = function loadStuff() {
//   var win, doc, img, header, enhancedClass;
//   // Quit early if older browser (e.g. IE8).
//   if (!('addEventListener' in window)) {
//     return;
//   }
//
//   win = window;
//   doc = win.document;
//   img = new Image();
//   header = doc.querySelector('.main');
//   enhancedClass = 'main-enhanced';
//
//   // Rather convoluted, but parses out the first mention of a background
//   // image url for the enhanced header, even if the style is not applied.
//   var bigSrc = (function() {
//     // Find all of the CssRule objects inside the inline stylesheet
//     var styles = doc.querySelector('style').sheet.cssRules;
//     // Fetch the background-image declaration...
//     var bgDecl = (function() {
//       // ...via a self-executing function, where a loop is run
//       var bgStyle, i, l = styles.length;
//       for (i = 0; i < l; i++) {
//         // ...checking if the rule is the one targeting the
//         // enhanced header.
//         if (styles[i].selectorText &&
//           styles[i].selectorText == '.' + enhancedClass) {
//           // If so, set bgDecl to the entire background-image
//           // value of that rule
//           bgStyle = styles[i].style.backgroundImage;
//           // ...and break the loop.
//           break;
//         }
//       }
//       // ...and return that text.
//       return bgStyle;
//     }());
//     // Finally, return a match for the URL inside the background-image
//     // by using a fancy regex i Googled up, if the bgDecl variable is
//     // assigned at all.
//     return bgDecl && bgDecl.match(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)[1];
//   }());
//
//   // Assign an onLoad handler to the dummy image *before* assigning the src
//   img.onload = function() {
//     header.className += ' ' + enhancedClass;
//   };
//   // Finally, trigger the whole preloading chain by giving the dummy
//   // image its source.
//   if (bigSrc) {
//     img.src = bigSrc;
//   }
// };
