$ -> 
  $('#released_on').datepicker( changeYear: true, yearRange: '1940:2000' )
  $('#like input').click (event) -> # this searches for the input button inside the div with an id of like. We add an event listner that checks for when this button is clicked.
    event.preventDefault() # this prevents the default behaviour, in this case posting the form.
    $.post( #this sends an ajax post instead
      $('#like form').attr('action') # this tells ajax to use the like form's action attribute. 
      (data) -> $('#like p').html(data).effect('highlight', color: '#fcd') #  returns the data from the from to the like div paraph element. this is a visual effect to show that the paragraph has been updated.
    )